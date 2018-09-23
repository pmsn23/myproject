import pandas as pd
import numpy as np

from bokeh.layouts import row, column
from bokeh.models import BoxSelectTool, LassoSelectTool, Spacer
from bokeh.plotting import figure, curdoc

muthayam_file = 'MuthayamPowerData.xlsx'
muthayambd_file = 'MuthayamBreakDownData.xlsx'
bogam_file = "BogamPowerData.xlsx"
bogambd_file = 'BogamBreakDownData.xlsx'
compalints_file = "ComplaintCalls.xlsx"

muthayam = pd.read_excel(muthayam_file)
bogam = pd.read_excel(bogam_file)

muthayambd = pd.read_excel(muthayambd_file)
bogambd = pd.read_excel(bogambd_file)

complaints = pd.read_excel(compalints_file)

muthayam.columns = muthayam.columns.str.strip().str.lower().str.replace('.', '').str.replace('%', 'Pct').str.replace(' ', '_').str.replace('(', '').str.replace(')', '')
bogam.columns = bogam.columns.str.strip().str.lower().str.replace('.', '').str.replace('%', 'Pct').str.replace(' ', '_').str.replace('(', '').str.replace(')', '')

muthayambd.columns = muthayambd.columns.str.strip().str.lower().str.replace('.', '').str.replace('%', 'Pct').str.replace(' ', '_').str.replace('(', '').str.replace(')', '')
bogambd.columns = bogambd.columns.str.strip().str.lower().str.replace('.', '').str.replace('%', 'Pct').str.replace(' ', '_').str.replace('(', '').str.replace(')', '')

complaints.columns = complaints.columns.str.strip().str.lower().str.replace('.', '').str.replace('%', 'Pct').str.replace(' ', '_').str.replace('(', '').str.replace(')', '')

muthayam = muthayam.drop(['customer_name', 'state','site','section','loc_no',"mw"], axis=1)
muthayambd = muthayambd.drop(['customer_name', 'state','site','section','loc_no',"mw"], axis=1)

muthayam.rename(columns={'m/c_availPct': 'machine_availPct'}, inplace=True)
muthayam["machine_availPct"] = muthayam["machine_availPct"].replace({"*":0})

muthayam["gen_date"] = pd.to_datetime(muthayam["gen_date"])
muthayambd["gen_date"] = pd.to_datetime(muthayambd["gen_date"])

muthayam = muthayam.sort_values(by='gen_date')
muthayambd = muthayambd.sort_values(by='gen_date')

complaints["bookeddate"] = pd.to_datetime(complaints["bookeddate"])

bogam = bogam.drop(['customer_name', 'state','site','section','loc_no',"mw"], axis=1)
bogambd = bogambd.drop(['customer_name', 'state','site','section','loc_no',"mw"], axis=1)

bogam.rename(columns={'m/c_availPct': 'machine_availPct'}, inplace=True)
bogam["machine_availPct"] = bogam["machine_availPct"].replace({"*":0})

bogam["gen_date"] = pd.to_datetime(bogam["gen_date"])
bogambd["gen_date"] = pd.to_datetime(bogambd["gen_date"])

bogam = bogam.sort_values(by='gen_date')
bogambd = bogambd.sort_values(by='gen_date')

y = muthayam["gen_kwh_day"]
x = muthayam["gen_hrs"]

TOOLS="pan,wheel_zoom,box_select,lasso_select,reset"

# create the scatter plot
p = figure(tools=TOOLS, plot_width=600, plot_height=600, min_border=10, min_border_left=50,
           toolbar_location="above", x_axis_location=None, y_axis_location=None,
           title="Linked Histograms")

p.background_fill_color = "#fafafa"
p.select(BoxSelectTool).select_every_mousemove = False
p.select(LassoSelectTool).select_every_mousemove = False

r = p.scatter(x, y, size=3, color="#3A5785", alpha=0.6)

# create the horizontal histogram
hhist, hedges = np.histogram(x, bins=20)
hzeros = np.zeros(len(hedges)-1)
hmax = max(hhist)*1.1

LINE_ARGS = dict(color="#3A5785", line_color=None)

ph = figure(toolbar_location=None, plot_width=p.plot_width, plot_height=200, x_range=p.x_range,
            y_range=(-hmax, hmax), min_border=10, min_border_left=50, y_axis_location="right")
ph.xgrid.grid_line_color = None
ph.yaxis.major_label_orientation = np.pi/4
ph.background_fill_color = "#fafafa"

ph.quad(bottom=0, left=hedges[:-1], right=hedges[1:], top=hhist, color="white", line_color="#3A5785")
hh1 = ph.quad(bottom=0, left=hedges[:-1], right=hedges[1:], top=hzeros, alpha=0.5, **LINE_ARGS)
hh2 = ph.quad(bottom=0, left=hedges[:-1], right=hedges[1:], top=hzeros, alpha=0.1, **LINE_ARGS)

# create the vertical histogram
vhist, vedges = np.histogram(y, bins=20)
vzeros = np.zeros(len(vedges)-1)
vmax = max(vhist)*1.1

pv = figure(toolbar_location=None, plot_width=200, plot_height=p.plot_height, x_range=(-vmax, vmax),
            y_range=p.y_range, min_border=10, y_axis_location="right")
pv.ygrid.grid_line_color = None
pv.xaxis.major_label_orientation = np.pi/4
pv.background_fill_color = "#fafafa"

pv.quad(left=0, bottom=vedges[:-1], top=vedges[1:], right=vhist, color="white", line_color="#3A5785")
vh1 = pv.quad(left=0, bottom=vedges[:-1], top=vedges[1:], right=vzeros, alpha=0.5, **LINE_ARGS)
vh2 = pv.quad(left=0, bottom=vedges[:-1], top=vedges[1:], right=vzeros, alpha=0.1, **LINE_ARGS)

layout = column(row(p, pv), row(ph, Spacer(width=200, height=200)))

curdoc().add_root(layout)
curdoc().title = "Selection Histogram"

def update(attr, old, new):
    inds = np.array(new['1d']['indices'])
    if len(inds) == 0 or len(inds) == len(x):
        hhist1, hhist2 = hzeros, hzeros
        vhist1, vhist2 = vzeros, vzeros
    else:
        neg_inds = np.ones_like(x, dtype=np.bool)
        neg_inds[inds] = False
        hhist1, _ = np.histogram(x[inds], bins=hedges)
        vhist1, _ = np.histogram(y[inds], bins=vedges)
        hhist2, _ = np.histogram(x[neg_inds], bins=hedges)
        vhist2, _ = np.histogram(y[neg_inds], bins=vedges)

    hh1.data_source.data["top"]   =  hhist1
    hh2.data_source.data["top"]   = -hhist2
    vh1.data_source.data["right"] =  vhist1
    vh2.data_source.data["right"] = -vhist2

r.data_source.on_change('selected', update)