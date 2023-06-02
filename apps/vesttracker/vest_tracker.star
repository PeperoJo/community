"""
Applet: Vest Tracker
Summary: Track your shares vesting
Description: Displays how much your shares has vested.
Author: Joseph Han (PeperoJo)
"""

load("humanize.star", "humanize")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

DEFAULT_TZ = "America/New_York"

DEFAULT_NAME = "CHSNP"
DEFAULT_PRICE = "5.42"
DEFAULT_AMOUNT = "46000"

DEFAULT_START = "2022-09-12T09:00:00Z"
DEFAULT_END = "2026-09-12T09:00:00Z"

DEFAULT_DELAY = 100
DEFAULT_DURATION = 120000
# in milliseconds

def main(config):
    return render.Root(
        delay = 100,
        show_full_animation = False,
        max_age = 120,
        child = render.Padding(
            pad = 1,
            child = render.Column(
                expanded = True,
                main_align = "space_between",
                children = [
                    showHeader(config),
                    showValues(config),
                    showDivider(config),
                    showMeta(config),
                ],
            ),
        ),
    )

def showHeader(config):
    child = render.Row(
        expanded = True,
        main_align = "space_between",
        children = [
            render.Text(
                content = config.get("share_name", DEFAULT_NAME),
                font = "tb-8",
                color = "#0a0",
            ),
            render.Text(
                color = "#444444",
                font = "tb-8",
                content = time.now().in_location(DEFAULT_TZ).format("3:04"),
            ),
        ],
    )
    return child

def showDivider(config):
    time_now = time.now().in_location(config.get("$tz", DEFAULT_TZ))
    time_start = config.get("date_start", DEFAULT_START)
    time_end = config.get("date_end", DEFAULT_END)

    time_passed = time_now - time.parse_time(time_start)
    time_total = time.parse_time(time_end) - time.parse_time(time_start)
    time_passed_percent = time_passed / time_total

    child = render.Column(
        children = [
            render.Box(width = 1000, height = 1, color = "#000000"),
            render.Stack(
                children = [
                    render.Box(width = 62, height = 1, color = "#222222"),
                    render.Box(width = int(62 * time_passed_percent), height = 1, color = "#4CA730"),
                ],
            ),
            render.Box(width = 1000, height = 1, color = "#000000"),
        ],
    )
    return child

def showValues(config):
    time_now = time.now().in_location(config.get("$tz", DEFAULT_TZ))
    time_start = config.get("date_start", DEFAULT_START)
    time_end = config.get("date_end", DEFAULT_END)

    # time_passed = time_now - time.parse_time(time_start)
    # time_total = time.parse_time(time_end) - time.parse_time(time_start)
    # time_passed_percent = time_passed/time_total

    # time gap is 100ms
    time_gap = time.parse_time("0000-01-01T00:00:00.1Z") - time.parse_time("0000-01-01T00:00:00Z")

    values = []

    frames = int(DEFAULT_DURATION / DEFAULT_DELAY)
    for i in range(frames):
        time_passed = time_now - time.parse_time(time_start) + i * time_gap
        time_total = time.parse_time(time_end) - time.parse_time(time_start)
        time_passed_percent = time_passed / time_total

        price = config.get("share_price", DEFAULT_PRICE)
        amount = config.get("share_amount", DEFAULT_AMOUNT)

        earned = time_passed_percent * float(price) * float(amount)

        child = render.Text(
            content = "$ " + str(humanize.comma(earned)),
            font = "tb-8",
            color = "#fff",
        )

        values.append(child)

    # print(time_total)
    # print(time_passed_percent)

    child = render.Animation(
        children = values,
    )

    return child

def showMeta(config):
    time_now = time.now().in_location(config.get("$tz", DEFAULT_TZ))
    time_start = config.get("date_start", DEFAULT_START)
    time_end = config.get("date_end", DEFAULT_END)

    time_passed = time_now - time.parse_time(time_start)
    time_total = time.parse_time(time_end) - time.parse_time(time_start)
    time_passed_percent = time_passed / time_total

    child = render.Row(
        expanded = True,
        main_align = "space_between",
        children = [
            render.Text(
                color = "#444444",
                font = "tb-8",
                content = str(int(time_passed_percent * 100)) + "%",
            ),
            render.Text(
                color = "#444444",
                font = "tb-8",
                content = "$ " + str(config.get("share_price", DEFAULT_PRICE)),
            ),
        ],
    )
    return child

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "share_name",
                name = "Share Name",
                desc = "What is your company called?",
                icon = "robot",
                default = DEFAULT_NAME,
            ),
            schema.Text(
                id = "share_price",
                name = "Share Value",
                desc = "How much is the share worth?",
                icon = "robot",
                default = DEFAULT_PRICE,
            ),
            schema.Text(
                id = "share_amount",
                name = "Share Amount",
                desc = "How many shares are you given?",
                icon = "robot",
                default = DEFAULT_AMOUNT,
            ),
            schema.DateTime(
                id = "date_start",
                name = "Vest Start Date",
                desc = "When do the shares start vesting?",
                icon = "calendar",
            ),
            schema.DateTime(
                id = "date_end",
                name = "Vest End Date",
                desc = "When do the shares end vesting?",
                icon = "calendar",
            ),
        ],
    )
