autoload -U +X bashcompinit && bashcompinit
autoload -U +X compinit && compinit

fpath=($fpath ~/.zsh/completion)

BREW_BIN="/usr/local/bin/brew"
if [ -f "/opt/homebrew/bin/brew" ]; then
    BREW_BIN="/opt/homebrew/bin/brew"
fi

if type "${BREW_BIN}" &> /dev/null; then
    export BREW_PREFIX="$("${BREW_BIN}" --prefix)"
    for bindir in "${BREW_PREFIX}/opt/"*"/libexec/gnubin"; do export PATH=$bindir:$PATH; done
    for bindir in "${BREW_PREFIX}/opt/"*"/bin"; do export PATH=$bindir:$PATH; done
    for mandir in "${BREW_PREFIX}/opt/"*"/libexec/gnuman"; do export MANPATH=$mandir:$MANPATH; done
    for mandir in "${BREW_PREFIX}/opt/"*"/share/man/man1"; do export MANPATH=$mandir:$MANPATH; done
fi

export EDITOR="code"
export PATH=$HOME/.docker/bin:$PATH

source $HOME/.antidote/antidote.zsh
source <(antidote init)

ANTIDOTE_HOME="$(antidote home)"
export ZSH="$ANTIDOTE_HOME"/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh
antidote bundle < ~/.zsh_plugins.txt

# aliases
alias c="clear"
alias ssologin="unsetprofile && aws sso login --profile default"
#alias pull="git pull"
#alias push="git push"
alias myip="dig +short -4 myip.opendns.com @resolver1.opendns.com"
alias python="python3"
alias pip="pip3"
alias tfi="tofu init"
alias tfpv='tofu plan -lock=false -var-file=environment.tfvars'
alias tfp="tofu plan -lock=false"
alias tflock="tofu providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64 -platform=darwin_arm64"
#alias toi="tofu init"
#alias top="tofu plan -lock=false"
#alias topv="tofu plan -lock=false -var-file=environment.tfvars"
alias tolock="tofu providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64 -platform=darwin_arm64"
alias tfdirlock='for dir in */; do if [ -d "$dir" ]; then echo "Processing $dir"; cd "$dir" && rm -rf .terraform && tofu init -upgrade && tflock && cd .. ; fi; done'

## Logging into the OM1 ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 888025091877.dkr.ecr.us-east-1.amazonaws.com

# functions
function listprofiles(){
  echo "Available AWS Profiles:\n"
  aws configure list-profiles
}

function setprofile() {
  export AWS_PROFILE=$1
  echo "AWS_PROFILE set to $AWS_PROFILE"
}

function unsetprofile() {
  unset AWS_PROFILE
  echo "AWS_PROFILE unset"
}

function get_account_id() {
  unset AWS_PROFILE
  aws sts get-caller-identity --query Account --output text --no-cli-pager --profile $1 
}

function check_logged_in() {
  if aws sts get-caller-identity --profile default > /dev/null 2>&1; then
    echo "Already Logged into AWS SSO"
  else
    echo "Authenticating AWS SSO"
    ssologin
  fi
}

# Make sure we are logged into AWS SSO with a valid session
check_logged_in

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
