from os.path import dirname, join

import numpy as np
import pandas.io.sql as psql
import pandas as pd
import _mysql
import MySQLdb as mdb

DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ')sZp27wh*f'
DB_NAME = 'WindMill'


from bokeh.plotting import figure
from bokeh.layouts import layout, widgetbox
from bokeh.models import ColumnDataSource, Div
from bokeh.models.widgets import Slider, Select, TextInput
from bokeh.io import curdoc

conn = mdb.connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME)
query = open(join(dirname(__file__), 'query.sql')).read()
power = psql.read_sql(query, conn)

power["color"] = np.where(power["gen_hrs"] > 18, "orange", "grey")
power["alpha"] = np.where(power["gen_hrs"] > 18, 0.9, 0.25)
power['date'] = pd.to_datetime(power['gen_date'])

print(power["site"])
axis_map = {
    "Power Generation(kwh/day)": "gen_kwh_day",
    "Power Generation(kwh/month-to-date)": "gen_kwh_mtd",
    "Power Generation(kwh/year-to-date": "gen_kwh_ytd",
    "Percentage Load Factor(day)": "Pctplf_day",
    "Percentage Load Factor(month-to-date)": "Pctplf_mtd ",
    "Percentage Load Factor(year-to-date)": "Pctplf_ytd",
    "Machine Available Percentage": "machine_availPct",
    "Power Generation (hrs)": "gen_hrs",
    "Operations (hrs)": "opr_hrs",    
}

desc = Div(text=open(join(dirname(__file__), "description.html")).read(), width=800)

# Create Input controls
min_month = Slider(title="Month (From)", value=1, start=1, end=12, step=1)
max_month = Slider(title="Month (To)", value=12, start=1, end=12, step=1)
min_year = Slider(title="Year (From)", start=2011, end=2018, value=2011, step=1)
max_year = Slider(title="Year (To)", start=2011, end=2018, value=2018, step=1)
site = Select(title="Site", value="Bogampatty",
               options=open(join(dirname(__file__), 'WindMill.txt')).read().split())

x_axis = Select(title="X Axis", options=sorted(axis_map.keys()), value="Power Generation (hrs)")
y_axis = Select(title="Y Axis", options=sorted(axis_map.keys()), value="Power Generation(kwh/day)")

# Create Column Data Source that will be used by the plot
source = ColumnDataSource(data=dict(x=[], y=[], color=[], title=[], year=[], revenue=[], alpha=[]))

TOOLTIPS=[
    ("Power", "@gen_kwh_day"),
    ("PLF", "@pctplf_day"),
    ("Gen. Hrs", "@gen_hrs")
]

p = figure(plot_height=600, plot_width=700, title="", toolbar_location=None, tooltips=TOOLTIPS)
p.circle(x="x", y="y", source=source, size=7, color="color", line_color=None, fill_alpha="alpha")


def select_power():
    site_val = site.value

    selected = power[
        (power.site == site.value) &
        (power.date.dt.month >= min_month.value) &
        (power.date.dt.month <= max_month.value) &
        (power.date.dt.year >= min_year.value) &
        (power.date.dt.year <= max_year.value) 
    ]
    if (site_val != "Bogampatty"):
        selected = selected[selected.site.str.contains(site_val)==True]
    return selected


def update():
    df = select_power()
    x_name = axis_map[x_axis.value]
    y_name = axis_map[y_axis.value]

    p.xaxis.axis_label = x_axis.value
    p.yaxis.axis_label = y_axis.value
    p.title.text = "%d Power Datapoint Selected" % len(df)
    source.data = dict(
        x=df[x_name],
        y=df[y_name],
        color=df["color"],
        gen_kwh_day=df["gen_kwh_day"],
        pctplf_day=df["Pctplf_day"],
        gen_hrs=df["gen_hrs"],
        alpha=df["alpha"],
    )

controls = [site, min_year, max_year, min_month, max_month, x_axis, y_axis]
for control in controls:
    control.on_change('value', lambda attr, old, new: update())

sizing_mode = 'fixed'  # 'scale_width' also looks nice with this example

inputs = widgetbox(*controls, sizing_mode=sizing_mode)
l = layout([
    [desc],
    [inputs, p],
], sizing_mode=sizing_mode)

update()  # initial load of the data

curdoc().add_root(l)
curdoc().title = "Power"