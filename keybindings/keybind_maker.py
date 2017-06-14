# encoding:utf-8
import json
import os
import re


modifier = {
    "ctrl": "ctrl",
    "cmd": "cmd",
    "alt": "alt",
    "shift": "shift"}


def make_keybindings_file():
    """create keybindings"""

    home_dir = os.environ["HOME"]
    keybindings_json = "Library/Application Support/Code/User/keybindings.json"
    vscode_keybindings_path = os.path.join(home_dir, keybindings_json)
    key_bind_json = []
    bind_json_list = [i for i in os.listdir("./") if re.search("[0-9]*", i).group(0)]
    for i in bind_json_list:
        with open(i) as f:
            binds = json.load(f)
        for bind in binds:
            keys = bind["key"].rsplit("+")
            new_key = []
            for key in keys:
                new_key.append(modifier[key] if key in modifier else key)
            bind["key"] = "+".join(new_key)
            key_bind_json.append(bind)
    with open(vscode_keybindings_path, "w") as f:
        json.dump(key_bind_json, f, sort_keys=True, indent=4)

if __name__ == "__main__":
    make_keybindings_file()
    print("keybindings.json Created")
