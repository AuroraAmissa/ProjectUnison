import tomllib
import tomli_w

def merge(base, new):
    out = {}
    keys = set(base.keys() | new.keys())

    for key in keys:
        if key in base and key in new:
            if type(base[key]) == dict or type(new[key]) == dict:
                assert type(base[key]) == dict and type(new[key]) == dict
                out[key] = merge(base[key], new[key])
            else:
                out[key] = new[key]
        elif key in base:
            out[key] = base[key]
        else:
            out[key] = new[key]

    return out


base = tomllib.loads(open("PandocRulebookBase/soupault_base.toml").read())

meta = tomllib.loads(open("templates/meta.toml").read())
base["widgets"]["page-title"]["default"] = meta["config"]["title"]
base["widgets"]["page-title"]["append"] = " | " + meta["config"]["title"]

if "entry" in meta:
    name = meta["entry"]["name"]
    path = meta["entry"]["path"]
    contents = f'<meta http-equiv="refresh" content="0; URL={path}"/>'
    open(f"build/soupault/site/{name}.html", "w").write(contents)

if "soupault" in meta:
    merged = merge(base, meta["soupault"])
else:
    merged = base

open("build/soupault/soupault.toml", "w").write(tomli_w.dumps(merged))
