import os
from kittens.tui.handler import result_handler

def main(args):
    pass

@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    sf = os.path.join(os.environ.get('XDG_RUNTIME_DIR', '/tmp'), 'kitty_split_state')
    try:
        state = open(sf).read().strip()
    except OSError:
        state = ''
    location, next_state = ('vsplit', 'h') if state == 'v' else ('hsplit', 'v')
    try:
        open(sf, 'w').write(next_state)
    except OSError:
        pass
    w = boss.window_id_map.get(target_window_id)
    boss.call_remote_control(w, ('launch', f'--location={location}', '--cwd=current'))
