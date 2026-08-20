#!/usr/bin/env python3
"""A stand-in for the TMS API, serving synthetic data for store screenshots.

    python3 tool/store/mock_api_server.py [port]      # default 8099

Then build a profile APK pointed at it and capture from that:

    flutter build apk --profile --target-platform android-arm64 \
        --dart-define=TMS_BASE_URL=http://10.0.2.2:8099

`10.0.2.2` is the host loopback as seen from an Android emulator. A profile build is
what makes this work at all: the main manifest sets `usesCleartextTraffic="false"`, and
only the debug and profile manifests override it. Profile is otherwise release-like —
AOT-compiled, no debug banner — so the pixels match what ships.

Why this exists
---------------
Store screenshots may not show production data: the live account carries a real
employee's name, ID and phone number, and its records are real business records. It is
also, right now, full of `Probe Test` rows left over from contract probing, which is
both unpublishable and unrepresentative. Every name, plate, phone number and address
below is invented for this purpose.

The shapes mirror `lib/data/remote/README.md` exactly — envelope `{success, message,
data}` everywhere except `GET /user`, which is bare; list rows nested at `data.data`
with `data.pagination` beside them; `start_time` in Dhaka wall-clock and `created_at`
in UTC, both `YYYY-MM-DD HH:mm:ss`.
"""

from __future__ import annotations

import json
import re
import sys
from datetime import datetime, timedelta
from http.server import BaseHTTPRequestHandler, HTTPServer

TOKEN = "screenshot-session-token"
COMPANY = "B-Trac Solutions Limited"

# Anchored to a fixed date so a re-run produces the same screenshots. Bump it if the
# captures ever need to look "current" again.
TODAY = datetime(2026, 8, 19, 9, 0, 0)


def wall(days: int, hour: int, minute: int = 0) -> str:
    """Dhaka wall-clock, the format `start_time` uses."""
    d = (TODAY + timedelta(days=days)).replace(hour=hour, minute=minute, second=0)
    return d.strftime("%Y-%m-%d %H:%M:%S")


def utc(days: int, hour: int, minute: int = 0) -> str:
    """UTC, the format `created_at` uses."""
    d = (TODAY + timedelta(days=days)).replace(hour=hour, minute=minute, second=0)
    return (d - timedelta(hours=6)).strftime("%Y-%m-%d %H:%M:%S")


ACCOUNT = {
    "name": "Nusrat Jahan",
    "designation": "Executive, Administration",
    "phone": "+8801711000000",
    "company_name": COMPANY,
    "id_no": "2-118",
    "department": "Administration",
}

EMPLOYEES = [
    {"id": 3011, "id_no": "2-118", "full_name": "Nusrat Jahan",
     "designation_name": "Executive, Administration", "department_name": "Administration"},
    {"id": 3042, "id_no": "2-204", "full_name": "Arif Hossain",
     "designation_name": "Senior Officer, Procurement", "department_name": "Procurement"},
    {"id": 3088, "id_no": "3-117", "full_name": "Sadia Karim",
     "designation_name": "Manager, Accounts", "department_name": "Finance"},
    {"id": 3120, "id_no": "4-063", "full_name": "Mahmudul Hasan",
     "designation_name": "Engineer, Field Services", "department_name": "Operations"},
]
for row in EMPLOYEES:
    row["company_name"] = COMPANY


def passenger(rid, status, pickup, drop, purpose, persons, start, created,
              used="Pickup & Drop", remarks=None, riders=(3011,)):
    return {
        "id": rid, "req_type": "passenger_vehicle", "status": status,
        "pickup_location": pickup, "drop_location": drop, "purpose": purpose,
        "used_type": used, "requisition_for": "Own User",
        "requisition_for_user": "Internal User", "customer_name": ACCOUNT["name"],
        "no_of_person": persons, "start_time": start, "created_at": created,
        "remarks": remarks, "_riders": list(riders),
    }


def logistics(rid, status, pickup, drop, capacity, weight, store, goods, start, created,
              remarks=None):
    return {
        "id": rid, "req_type": "logistic_support", "status": status,
        "pickup_location": pickup, "drop_location": drop,
        "requisition_for": "Cover Van", "customer_name": ACCOUNT["name"],
        "user_department": "Operations", "loading_capacity": capacity,
        "goods_weight": weight, "store_name": store, "goods_details": goods,
        "start_time": start, "created_at": created, "remarks": remarks, "_riders": [],
    }


# Newest first, which is the order the server returns and the list screen preserves.
REQUISITIONS = [
    passenger(4821, "Pending", "Banani Head Office", "Uttara Sector 7",
              "Client meeting at vendor office", 3, wall(1, 9, 30), utc(0, 12, 10),
              remarks="Return by 2 PM", riders=(3011, 3042)),
    passenger(4817, "Vehicle Assigned", "Banani Head Office",
              "Hazrat Shahjalal International Airport", "Airport pickup for visiting auditor",
              2, wall(0, 16, 0), utc(-1, 11, 5), used="Pickup", riders=(3011,)),
    passenger(4809, "Approved", "Gulshan 1 Circle", "Savar EPZ",
              "Quarterly site inspection", 4, wall(2, 8, 0), utc(-1, 9, 45),
              riders=(3011, 3120, 3088)),
    logistics(4802, "Approved", "Tejgaon Warehouse", "Chattogram Port Depot",
              "3 Ton", "850 kg", "Tejgaon Central Store",
              "Spare parts for depot handover", wall(3, 7, 0), utc(-2, 14, 20)),
    passenger(4795, "Pending", "Banani Head Office", "Motijheel Corporate Branch",
              "Document handover to branch", 1, wall(1, 14, 0), utc(-2, 10, 0)),
    passenger(4788, "Approved", "Mirpur DOHS", "Banani Head Office",
              "Staff pickup for month-end closing", 2, wall(-1, 8, 30), utc(-3, 7, 30)),
    logistics(4780, "Vehicle Assigned", "Gazipur Plant", "Tejgaon Warehouse",
              "5 Ton", "1200 kg", "Gazipur Plant Store", "Packaging material transfer",
              wall(-1, 6, 30), utc(-4, 13, 15)),
    passenger(4771, "Rejected", "Banani Head Office", "Cox's Bazar",
              "Team offsite travel", 6, wall(-3, 6, 0), utc(-6, 9, 0),
              remarks="Rejected — use inter-city bus allowance"),
    passenger(4762, "Approved", "Banani Head Office", "Dhanmondi 27",
              "Vendor contract signing", 2, wall(-5, 10, 0), utc(-8, 8, 40)),
    passenger(4750, "Cancel", "Banani Head Office", "Bashundhara R/A",
              "Site survey — postponed", 3, wall(-8, 9, 0), utc(-11, 6, 25)),
    passenger(4741, "Pending", "Banani Head Office", "Narayanganj Depot",
              "Monthly stock verification", 2, wall(4, 8, 30), utc(-12, 12, 0)),
    logistics(4733, "Cancel", "Tejgaon Warehouse", "Mymensingh Branch",
              "2 Ton", "400 kg", "Tejgaon Central Store", "Branch furniture move",
              wall(-12, 7, 0), utc(-14, 10, 10)),
]

DRIVER = {"name": "Jashim Uddin", "phone": "+8801711000111", "id_no": "D-204"}
VEHICLE = {"registration_number": "DHAKA METRO GA 11-2847", "model": "Toyota Hiace",
           "type": "Microbus"}


def list_row(req: dict) -> dict:
    """A list row: the detail fields the server omits are stripped here on purpose."""
    row = {k: v for k, v in req.items()
           if not k.startswith("_") and k not in {"purpose", "goods_details"}}
    row["purpose" if req["req_type"] == "passenger_vehicle" else "goods_details"] = (
        req.get("purpose") or req.get("goods_details"))
    return row


def detail(req: dict) -> dict:
    """A detail response: requester, department, riders, audit trail, and — when the
    trip is assigned — the driver and vehicle the list never carries."""
    body = {k: v for k, v in req.items() if not k.startswith("_")}
    body.update({
        "end_time": None,
        "department_name": ACCOUNT["department"],
        "company_name": COMPANY,
        "created_by_name": ACCOUNT["name"],
        "created_by_id_no": ACCOUNT["id_no"],
        "employees": [
            {"id": e["id"], "id_no": e["id_no"], "full_name": e["full_name"]}
            for e in EMPLOYEES if e["id"] in req["_riders"]
        ],
        "audit_logs": [
            {"id": req["id"] * 10 + 1, "requisition_status": "Pending",
             "remarks": "Requisition raised", "created_by_name": ACCOUNT["name"],
             "created_by_id_no": ACCOUNT["id_no"], "created_at": req["created_at"]},
        ],
    })
    if req["status"] in {"Approved", "Vehicle Assigned"}:
        body["audit_logs"].append(
            {"id": req["id"] * 10 + 2, "requisition_status": "Approved",
             "remarks": "Approved by transport desk", "created_by_name": "Kamrul Ahsan",
             "created_by_id_no": "1-042", "created_at": req["created_at"]})
    if req["status"] == "Vehicle Assigned":
        body["audit_logs"].append(
            {"id": req["id"] * 10 + 3, "requisition_status": "Vehicle Assigned",
             "remarks": "Vehicle and driver assigned", "created_by_name": "Kamrul Ahsan",
             "created_by_id_no": "1-042", "created_at": req["created_at"]})
        body["driver"] = DRIVER
        body["vehicle"] = VEHICLE
    if req["status"] == "Rejected":
        body["audit_logs"].append(
            {"id": req["id"] * 10 + 4, "requisition_status": "Rejected",
             "remarks": req.get("remarks") or "Rejected", "created_by_name": "Kamrul Ahsan",
             "created_by_id_no": "1-042", "created_at": req["created_at"]})
    return body


def envelope(data, message="Success"):
    return {"success": True, "message": message, "data": data}


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):  # quieter than the default access log
        sys.stderr.write("  mock %s %s\n" % (self.command, self.path.split("?")[0]))

    def _send(self, payload, status=200):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        path = self.path.split("?")[0]
        length = int(self.headers.get("Content-Length") or 0)
        if length:
            self.rfile.read(length)
        if path == "/login":
            self._send(envelope({"token": TOKEN, **{k: ACCOUNT[k] for k in
                                                    ("name", "designation", "phone",
                                                     "company_name")}}, "Login successful"))
        elif path == "/logout":
            self._send(envelope(None, "Logged out"))
        elif re.fullmatch(r"/requisitions/\d+/cancel", path):
            rid = int(path.split("/")[2])
            match = next((r for r in REQUISITIONS if r["id"] == rid), None)
            if match is None:
                self._send({"success": False, "message": "Requisition not found"}, 404)
            else:
                cancelled = dict(match, status="Cancel")
                self._send(envelope(detail(cancelled), "Requisition cancelled"))
        elif path == "/requisitions":
            self._send(envelope(detail(REQUISITIONS[0]), "Requisition created"), 201)
        else:
            self._send({"success": False, "message": "Not found"}, 404)

    def do_PUT(self):
        length = int(self.headers.get("Content-Length") or 0)
        if length:
            self.rfile.read(length)
        self._send(envelope(detail(REQUISITIONS[0]), "Requisition updated"))

    def do_GET(self):
        path = self.path.split("?")[0]
        if path == "/user":
            # Bare object, no envelope — this endpoint really is the odd one out.
            self._send({
                "id": 3011, "user_name": "nusrat.jahan@btracsolutions.com",
                "employee_id": 3011, "role_id": 4, "active_status": "Active",
                "created_at": "2024-02-11 04:30:00",
                "last_pasword_updated_at": "2026-06-02 05:15:00",
            })
        elif path == "/requisitions/employees":
            self._send(envelope(EMPLOYEES))
        elif re.fullmatch(r"/requisitions/\d+", path):
            rid = int(path.rsplit("/", 1)[1])
            match = next((r for r in REQUISITIONS if r["id"] == rid), None)
            if match is None:
                self._send({"success": False, "message": "Requisition not found"}, 404)
            else:
                self._send(envelope(detail(match)))
        elif path == "/requisitions":
            self._send(envelope({
                "data": [list_row(r) for r in REQUISITIONS],
                "pagination": {"current_page": 1, "per_page": 100,
                               "total": len(REQUISITIONS), "last_page": 1},
            }))
        else:
            self._send({"success": False, "message": "Not found"}, 404)


def main() -> None:
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8099
    server = HTTPServer(("0.0.0.0", port), Handler)
    print(f"mock TMS API on http://0.0.0.0:{port}  "
          f"({len(REQUISITIONS)} requisitions, sign in with any credentials)")
    server.serve_forever()


if __name__ == "__main__":
    main()
