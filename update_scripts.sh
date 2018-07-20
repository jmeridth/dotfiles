#!/bin/bash

curl -fLo git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
curl -fLo git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -fLo tmuxinator.bash https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.bash


if [[ "$OSTYPE" == "darwin"* ]]; then
  sudo curl -fL https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o $(brew --prefix)/etc/bash_completion.d/docker
  sudo curl -fL https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o $(brew --prefix)/etc/bash_completion.d/docker-compose
fi

if [[ "$OSTYPE" == "linux"* ]]; then
  sudo curl -fL https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker
  sudo curl -fL https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
fi
