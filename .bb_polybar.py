#!/usr/bin/env python3
"""
Editor acotado del current.ini de polybar para BoladoBSPWM/hardware.sh.
Lee qué hacer de variables de entorno (así se compone fácil desde bash):

  BB_REMOVE_BATTERY=1   -> quita 'battery' de modules-right en [bar/pill]
  BB_BAT=BAT0           -> en [module/battery]: battery = BAT0
  BB_ADP=ADP0           -> en [module/battery]: adapter = ADP0
  BB_IFACE=wlan0        -> en [module/network]: interface = wlan0
  BB_NETTYPE=wireless   -> en [module/network]: interface-type + labels segun tipo

argv[1] = ruta a current.ini
argv[2] = "pillmonitor" (opcional) -> fuerza monitor = ${env:MONITOR:} en [bar/pill]
"""
import os, sys, re

path = sys.argv[1]
extra = sys.argv[2] if len(sys.argv) > 2 else ""
lines = open(path, encoding="utf-8").read().split("\n")


def section_range(name):
    """Devuelve (inicio, fin) de la seccion [name] (fin exclusivo)."""
    start = None
    for i, l in enumerate(lines):
        s = l.strip()
        if s == "[" + name + "]":
            start = i
            continue
        if start is not None and s.startswith("[") and s.endswith("]"):
            return start, i
    if start is not None:
        return start, len(lines)
    return None, None


def set_key(name, key, value):
    a, b = section_range(name)
    if a is None:
        return False
    pat = re.compile(r"^\s*" + re.escape(key) + r"\s*=")
    for i in range(a, b):
        if pat.match(lines[i]):
            lines[i] = "{} = {}".format(key, value)
            return True
    # si no existe, insertarla justo tras la cabecera
    lines.insert(a + 1, "{} = {}".format(key, value))
    return True


# --- batería: nombre o eliminación del módulo en la pill ---
if os.environ.get("BB_REMOVE_BATTERY") == "1":
    a, b = section_range("bar/pill")
    if a is not None:
        for i in range(a, b):
            if lines[i].strip().startswith("modules-right"):
                key, val = lines[i].split("=", 1)
                toks = val.split()
                toks = [t for t in toks if t != "battery"]
                out = []
                for t in toks:                       # colapsar seps consecutivos
                    if t == "sep" and (not out or out[-1] == "sep"):
                        continue
                    out.append(t)
                while out and out[-1] == "sep":
                    out.pop()
                while out and out[0] == "sep":
                    out.pop(0)
                lines[i] = key + "= " + " ".join(out)
                break

if os.environ.get("BB_BAT"):
    set_key("module/battery", "battery", os.environ["BB_BAT"])
if os.environ.get("BB_ADP"):
    set_key("module/battery", "adapter", os.environ["BB_ADP"])

# --- red: interfaz + tipo + etiquetas ---
iface = os.environ.get("BB_IFACE")
nettype = os.environ.get("BB_NETTYPE")
if iface:
    set_key("module/network", "interface", iface)
if nettype:
    set_key("module/network", "interface-type", nettype)
    if nettype == "wired":
        # las wifi (essid/signal) no aplican en cable -> mostrar IP local
        set_key("module/network", "label-connected", '" %local_ip%"')
        set_key("module/network", "label-disconnected", '" sin red"')
    else:
        set_key("module/network", "label-connected", '" %essid% %signal%%"')

# --- pill por monitor ---
if extra == "pillmonitor":
    set_key("bar/pill", "monitor", "${env:MONITOR:}")

open(path, "w", encoding="utf-8").write("\n".join(lines))
print("[.bb_polybar] current.ini actualizado")
