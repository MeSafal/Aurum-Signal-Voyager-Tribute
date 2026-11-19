#!/usr/bin/env python3
"""Regenerate assets/data/v1_distance.json from JPL Horizons.

Usage: python3 tool/fetch_ephemeris.py
"""

import datetime as dt
import json
import math
import pathlib
import urllib.parse
import urllib.request

API = "https://ssd.jpl.nasa.gov/api/horizons.api"
START = "2026-01-01"
STOP = "2032-12-31"
MILESTONE_KM = 25_902_068_356.0
OUTPUT = pathlib.Path(__file__).resolve().parents[1] / "assets" / "data" / "v1_distance.json"


def fetch() -> dict:
    params = {
        "format": "json",
        "COMMAND": "' -31 '".replace(" ", ""),
        "OBJ_DATA": "'NO'",
        "MAKE_EPHEM": "'YES'",
        "EPHEM_TYPE": "'VECTORS'",
        "CENTER": "'500@399'",
        "START_TIME": f"'{START}'",
        "STOP_TIME": f"'{STOP}'",
        "STEP_SIZE": "'1 d'",
        "VEC_TABLE": "'2'",
        "OUT_UNITS": "'KM-S'",
        "REF_PLANE": "'ECLIPTIC'",
        "VEC_LABELS": "'NO'",
        "CAL_FORMAT": "'CAL'",
    }
    url = f"{API}?{urllib.parse.urlencode(params)}"
    request = urllib.request.Request(url, headers={"User-Agent": "aurum-signal-ephemeris/1.0"})
    with urllib.request.urlopen(request, timeout=120) as response:
        payload = json.load(response)
    if "error" in payload:
        raise RuntimeError(payload["error"])
    return payload


def parse(result: str) -> list[dict]:
    lines = result.splitlines()
    try:
        start = lines.index("$$SOE")
        end = lines.index("$$EOE")
    except ValueError as exc:
        raise RuntimeError("Horizons response did not contain $$SOE/$$EOE") from exc

    points: list[dict] = []
    date = None
    for line in lines[start + 1 : end]:
        stripped = line.strip()
        if "A.D." in stripped:
            calendar = stripped.split("A.D.", 1)[1].strip()
            date = dt.datetime.strptime(calendar[:19], "%Y-%b-%d %H:%M:%S").date().isoformat()
            continue
        numbers = stripped.split()
        if date and len(numbers) >= 3:
            try:
                x, y, z = (float(value) for value in numbers[:3])
            except ValueError:
                continue
            points.append({"date": date, "km": math.sqrt(x * x + y * y + z * z)})
            date = None
    if not points:
        raise RuntimeError("No vectors parsed from Horizons response")
    return points


def main() -> None:
    payload = fetch()
    points = parse(payload["result"])
    document = {
        "source": API,
        "target": "Voyager 1 (-31)",
        "center": "Earth centre (500@399)",
        "units": "km",
        "generatedAt": dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds"),
        "points": points,
    }
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(document, separators=(",", ":")) + "\n", encoding="utf-8")

    target = dt.datetime(2026, 11, 18, 10, 16, 7)
    before = dt.datetime.fromisoformat(points[0]["date"])
    for first, second in zip(points, points[1:]):
        left = dt.datetime.fromisoformat(first["date"])
        right = dt.datetime.fromisoformat(second["date"])
        if left <= target <= right:
            fraction = (target - left) / (right - left)
            estimate = first["km"] + fraction * (second["km"] - first["km"])
            error = abs(estimate - MILESTONE_KM) / MILESTONE_KM * 100
            print(f"points={len(points)} first={before.date()} last={second['date']}")
            print(f"milestone estimate={estimate:,.0f} km error={error:.4f}%")
            return
    raise RuntimeError("Milestone date outside table")


if __name__ == "__main__":
    main()
