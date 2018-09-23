SELECT gen_date,
site,
gen_kwh_day,
gen_kwh_mtd,
gen_kwh_ytd,
Pctplf_day,
Pctplf_mtd,
Pctplf_ytd,
machine_availPct,
gen_hrs,
opr_hrs
FROM muthayampw 
UNION
SELECT gen_date,
site,
gen_kwh_day,
gen_kwh_mtd,
gen_kwh_ytd,
Pctplf_day,
Pctplf_mtd,
Pctplf_ytd,
machine_availPct,
gen_hrs,
opr_hrs
From bogampw 
