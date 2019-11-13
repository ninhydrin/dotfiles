from time import strftime
prompt_msg = lambda: dt.now().strftime('[ %Y-%m-%d %H:%M:%S ]')
PROMPT = "-[{BOLD_WHITE}{user}{INTENSE_GREEN}@{BOLD_INTENSE_WHITE}{hostname}]-({BACKGROUND_GREEN}0{NO_COLOR}{BOLD_WHITE})"
PROMPT += prompt_msg + "-{INTENSE_YELLOW} [ {cwd} ] {GREEN}$ "
