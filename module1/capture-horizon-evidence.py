#!/usr/bin/env python3
"""Capture Module 1 Horizon pages with an authenticated Playwright session."""

from __future__ import annotations

import os
import re
from pathlib import Path

from playwright.sync_api import Page, sync_playwright

BASE_URL = os.environ.get("HORIZON_URL", "http://192.168.2.10/dashboard").rstrip("/")
USERNAME = os.environ.get("HORIZON_USERNAME", "demo")
PROJECT = os.environ.get("HORIZON_PROJECT", "demo")
PASSWORD = os.environ["HORIZON_PASSWORD"]
OUTPUT_DIR = Path(os.environ.get("EVIDENCE_DIR", "module1/evidence/horizon"))

PAGES = [
    ("01-compute-overview.png", "/project/", "h1", "Overview"),
    ("02-compute-instances-active.png", "/project/instances/", "h1", "Instances"),
    ("03-compute-images.png", "/project/images/", "h1", "Images"),
    ("04-compute-key-pairs.png", "/project/key_pairs/", "h1", "Key Pairs"),
    ("05-network-security-groups.png", "/project/security_groups/", "h1", "Security Groups"),
    ("06-network-networks.png", "/project/networks/", "h1", "Networks"),
    ("07-network-routers.png", "/project/routers/", "h1", "Routers"),
    ("08-orchestration-stacks.png", "/project/stacks/", "h1", "Stacks"),
    ("09-object-store-containers.png", "/project/containers/", "h1", "Containers"),
]


def login(page: Page) -> None:
    page.goto(f"{BASE_URL}/auth/login/?next=/dashboard/", wait_until="networkidle")
    page.get_by_label("User Name").fill(USERNAME)
    page.get_by_label("Password").fill(PASSWORD)
    page.get_by_role("button", name="Sign In").click()
    page.wait_for_url("**/dashboard/**", timeout=30_000)
    current_project = page.locator("a.dropdown-toggle").filter(has_text="invisible_to_admin")
    if current_project.count() > 0:
        current_project.first.click()
        page.locator('a[href*="/auth/switch/"]', has_text=PROJECT).first.click()
        page.wait_for_load_state("networkidle")


def capture(page: Page, filename: str, path: str, selector: str, expected: str) -> None:
    page.goto(f"{BASE_URL}{path}", wait_until="networkidle")
    page.locator(selector).filter(has_text=expected).first.wait_for(timeout=30_000)
    page.screenshot(path=OUTPUT_DIR / filename, full_page=True)
    print(f"captured {filename}: {page.title()}")


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1600, "height": 1100})
        login(page)
        for item in PAGES:
            capture(page, *item)
        browser.close()


if __name__ == "__main__":
    main()
