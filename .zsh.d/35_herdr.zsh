function _herdr_sessions() {
  local -a sessions
  sessions=(${(f)"$(herdr session list --json 2>/dev/null | uv run python -c "
import json,sys
for s in json.load(sys.stdin).get('sessions',[]):
  st='running' if s.get('running') else 'stopped'
  print(f\"{s['name']}:{st}\")
" 2>/dev/null)"})
  _describe 'session' sessions
}

function _herdr_workspaces() {
  local -a workspaces
  workspaces=(${(f)"$(herdr workspace list 2>/dev/null | uv run python -c "
import json,sys
for w in json.load(sys.stdin).get('result',{}).get('workspaces',[]):
  print(f\"{w['workspace_id']}:{w.get('label','')} ({w['tab_count']} tabs)\")
" 2>/dev/null)"})
  _describe 'workspace' workspaces
}

function _herdr_tabs() {
  local -a tabs
  tabs=(${(f)"$(herdr tab list 2>/dev/null | uv run python -c "
import json,sys
for t in json.load(sys.stdin).get('result',{}).get('tabs',[]):
  print(f\"{t['tab_id']}:{t.get('label','')} [{t['workspace_id']}]\")
" 2>/dev/null)"})
  _describe 'tab' tabs
}

function _herdr_panes() {
  local -a panes
  panes=(${(f)"$(herdr pane list 2>/dev/null | uv run python -c "
import json,sys
for p in json.load(sys.stdin).get('result',{}).get('panes',[]):
  print(f\"{p['pane_id']}:{p.get('label','') or p.get('agent','')} [{p.get('tab_id','')}]\")
" 2>/dev/null)"})
  _describe 'pane' panes
}

function _herdr_agents() {
  local -a agents
  agents=(${(f)"$(herdr agent list 2>/dev/null | uv run python -c "
import json,sys
for a in json.load(sys.stdin).get('result',{}).get('agents',[]):
  print(f\"{a.get('terminal_id',a.get('pane_id',''))}:{a['agent']} ({a['agent_status']}) [{a.get('workspace_id','')}]\")
" 2>/dev/null)"})
  _describe 'agent' agents
}

function _herdr_integration_agents() {
  local -a int_agents
  int_agents=(
    'pi' 'claude' 'codex' 'copilot' 'cursor' 'devin'
    'droid' 'kimi' 'opencode' 'kilo' 'hermes' 'qodercli' 'omp'
  )
  _describe 'agent' int_agents
}

function _herdr() {
  local -a subcmds
  subcmds=(
    'workspace:Manage workspaces'
    'tab:Manage tabs'
    'pane:Manage panes'
    'agent:Manage agents'
    'session:Manage sessions'
    'server:Server control'
    'worktree:Git worktree helpers'
    'wait:Wait for output or agent status'
    'integration:Install/uninstall agent integrations'
    'notification:Show notifications'
    'config:Configuration commands'
    'channel:Update channel management'
    'status:Show server/client status'
    'update:Download and install latest version'
  )

  _arguments -C \
    '1:subcommand:->subcmd' \
    '*::arg:->args' \
    '--session[Named session]:session name:_herdr_sessions' \
    '--remote[Connect to remote host]:ssh target:' \
    '--no-session[Start without a session]' \
    '--default-config[Print default config]' \
    '--version[Show version]' \
    '--help[Show help]'

  case "$state" in
    subcmd)
      _describe 'herdr subcommand' subcmds
      ;;
    args)
      case "$words[1]" in
        workspace)
          local -a ws_cmds
          ws_cmds=(
            'list:List workspaces'
            'create:Create a workspace'
            'get:Get workspace info'
            'focus:Focus a workspace'
            'rename:Rename a workspace'
            'close:Close a workspace'
          )
          _arguments -C '1:command:->wscmd' '*::arg:->wsargs'
          case "$state" in
            wscmd) _describe 'workspace command' ws_cmds ;;
            wsargs)
              case "$words[1]" in
                get|focus|close) _herdr_workspaces ;;
                rename) _herdr_workspaces ;;
                create) _arguments '--cwd[Working directory]:path:_directories' '--label[Label]:label:' '--focus' '--no-focus' ;;
              esac ;;
          esac
          ;;
        tab)
          local -a tab_cmds
          tab_cmds=(
            'list:List tabs'
            'create:Create a tab'
            'get:Get tab info'
            'focus:Focus a tab'
            'rename:Rename a tab'
            'close:Close a tab'
          )
          _arguments -C '1:command:->tcmd' '*::arg:->targs'
          case "$state" in
            tcmd) _describe 'tab command' tab_cmds ;;
            targs)
              case "$words[1]" in
                get|focus|close|rename) _herdr_tabs ;;
                create) _arguments '--workspace[Workspace]:workspace:_herdr_workspaces' '--cwd[Working directory]:path:_directories' '--label[Label]:label:' '--focus' '--no-focus' ;;
              esac ;;
          esac
          ;;
        pane)
          local -a pane_cmds
          pane_cmds=(
            'list:List panes'
            'current:Get current pane'
            'get:Get pane info'
            'layout:Show pane layout'
            'process-info:Show process info'
            'neighbor:Get neighboring pane'
            'edges:Get pane edges'
            'focus:Focus direction'
            'resize:Resize pane'
            'zoom:Toggle zoom'
            'rename:Rename pane'
            'read:Read pane output'
            'split:Split pane'
            'swap:Swap panes'
            'move:Move pane'
            'close:Close pane'
            'send-text:Send text to pane'
            'send-keys:Send keys to pane'
            'run:Run command in pane'
          )
          _arguments -C '1:command:->pcmd' '*::arg:->pargs'
          case "$state" in
            pcmd) _describe 'pane command' pane_cmds ;;
            pargs)
              case "$words[1]" in
                get|close|read|send-text|send-keys|run|rename|zoom) _herdr_panes ;;
                split) _arguments '1:pane:_herdr_panes' '--direction[Split direction]:(right down)' '--cwd[Working directory]:path:_directories' '--ratio[Split ratio]:ratio:' ;;
                focus) _arguments '--direction[Direction]:(left right up down)' ;;
                resize) _arguments '--direction[Direction]:(left right up down)' '--amount[Amount]:amount:' ;;
              esac ;;
          esac
          ;;
        agent)
          local -a agent_cmds
          agent_cmds=(
            'list:List agents'
            'get:Get agent info'
            'read:Read agent output'
            'send:Send text to agent'
            'rename:Rename agent'
            'focus:Focus agent'
            'wait:Wait for agent status'
            'attach:Attach to agent'
            'start:Start an agent'
            'explain:Explain agent detection'
          )
          _arguments -C '1:command:->acmd' '*::arg:->aargs'
          case "$state" in
            acmd) _describe 'agent command' agent_cmds ;;
            aargs)
              case "$words[1]" in
                get|read|send|rename|focus|attach|explain) _herdr_agents ;;
                wait) _arguments '1:agent:_herdr_agents' '--status[Status]:(idle working blocked done unknown)' '--timeout[Timeout ms]:ms:' ;;
                start) _arguments '1:name:' '--cwd[Working directory]:path:_directories' '--workspace[Workspace]:workspace:_herdr_workspaces' '--split[Split direction]:(right down)' ;;
              esac ;;
          esac
          ;;
        session)
          local -a sess_cmds
          sess_cmds=(
            'list:List sessions'
            'attach:Attach to session'
            'stop:Stop a session'
            'delete:Delete a session'
          )
          _arguments -C '1:command:->scmd' '*::arg:->sargs'
          case "$state" in
            scmd) _describe 'session command' sess_cmds ;;
            sargs)
              case "$words[1]" in
                attach|stop|delete) _herdr_sessions ;;
              esac ;;
          esac
          ;;
        server)
          local -a srv_cmds
          srv_cmds=(
            'stop:Stop the running server'
            'live-handoff:Hand off to new server'
            'reload-config:Reload config.toml'
            'agent-manifests:Show agent manifests'
            'update-agent-manifests:Fetch and reload manifests'
            'reload-agent-manifests:Reload manifests'
          )
          _describe 'server command' srv_cmds
          ;;
        worktree)
          local -a wt_cmds
          wt_cmds=(
            'list:List worktrees'
            'create:Create a worktree'
            'open:Open existing worktree'
            'remove:Remove worktree'
          )
          _describe 'worktree command' wt_cmds
          ;;
        wait)
          local -a wait_cmds
          wait_cmds=(
            'output:Wait for output match'
            'agent-status:Wait for agent status'
          )
          _arguments -C '1:command:->wcmd' '*::arg:->wargs'
          case "$state" in
            wcmd) _describe 'wait command' wait_cmds ;;
            wargs)
              case "$words[1]" in
                output) _arguments '1:pane:_herdr_panes' '--match[Match text]:text:' '--source[Source]:(visible recent recent-unwrapped)' '--timeout[Timeout ms]:ms:' '--regex' ;;
                agent-status) _arguments '1:pane:_herdr_panes' '--status[Status]:(idle working blocked done unknown)' '--timeout[Timeout ms]:ms:' ;;
              esac ;;
          esac
          ;;
        integration)
          local -a int_cmds
          int_cmds=(
            'install:Install agent integration'
            'uninstall:Uninstall agent integration'
            'status:Show integration status'
          )
          _arguments -C '1:command:->icmd' '*::arg:->iargs'
          case "$state" in
            icmd) _describe 'integration command' int_cmds ;;
            iargs)
              case "$words[1]" in
                install|uninstall) _herdr_integration_agents ;;
              esac ;;
          esac
          ;;
        notification)
          _arguments '1:title:' '--body[Body text]:text:' '--position[Position]:(top-left top-right bottom-left bottom-right)' '--sound[Sound]:(none done request)'
          ;;
        config)
          local -a cfg_cmds
          cfg_cmds=('reset-keys:Back up and remove custom keybindings')
          _describe 'config command' cfg_cmds
          ;;
        channel)
          local -a ch_cmds
          ch_cmds=(
            'show:Print current channel'
            'set:Set update channel'
          )
          _arguments -C '1:command:->chcmd' '*::arg:->chargs'
          case "$state" in
            chcmd) _describe 'channel command' ch_cmds ;;
            chargs)
              case "$words[1]" in
                set) _arguments '1:channel:(stable preview)' ;;
              esac ;;
          esac
          ;;
        status)
          local -a st_cmds
          st_cmds=(
            'server:Show server status'
            'client:Show client status'
          )
          _describe 'status command' st_cmds
          ;;
      esac
      ;;
  esac
}

_herdr "$@"

compdef _herdr herdr
