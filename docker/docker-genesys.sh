#!/bin/bash

default_git_repo=https://github.com/rlcancian2/Genesys-Simulator
container_command=/bin/bash  # default container command

function handle_load {
        echo "Loading image..."
        docker load -i genesys-image.tar
}

function handle_save {
        docker commit genesys-container genesys-image
}

function handle_build {
        echo "Building new image..."
        cd ..
        GENESYS = $(pwd)

        # Buildando a imagem
        docker build -t genesys-image .

        # Criando pasta do pacote
        mkdir GenesysPkg

        # Adicionando imagem compactada a pasta do pacote
        cd GenesysPkg
        docker save -o genesys-image.tar genesys-image:latest

        # Adicionando script de execução da imagem
        cp GENESYS/docker_scripts/start_container.sh ./

        # Compactando o pacote da imagem com o script
        cd ..
        tar -cvf GenesysPkg.tar GenesysPkg

        # Limpando execução do script
        rm -r GenesysPkg
}

function prepare_environment {
        echo "Iniciando container do Genesys..."
        # Working directory of socket file
        export XSOCK=/tmp/.X11-unix
        # Temporary access token 
        export XAUTH=/tmp/.docker.xauth

        # Check if temoporary token file exists, if not create one
        [ -e "$XAUTH" ] || touch "$XAUTH"

        # Generate new access token, set the Authentication Family to 'FamilyWild'
        xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

        docker rm genesys-container

}

function run_genesys {
        prepare_environment

        # Start container
        docker run -it --net host --name genesys-container \
                -e DISPLAY=$DISPLAY \
                -e XAUTHORITY=$XAUTH \
                -e command=$command \
                -v $XSOCK:$XSOCK \
                -v $XAUTH:$XAUTH \
                genesys-image \
                ./run-genesys.sh
}

echo -e "\n========= Bem vindo ao Genesys docker ========= \n\n" 


# Checando se a imagem do genesys já está instalada na máquina
IMAGE_NAME=genesys-image
if docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo -e "Foi encontrada uma imagem do Genesys localmente!\n"
else
    echo "Não foi encontrada uma imagem do Genesys localmente. Baixando imagem a partir do Docker Hub..."
    echo -e "Isto pode levar alguns minutos\n"
    docker pull modsimgrupo6/genesys:1.0
    docker image tag modsimgrupo6/genesys:latest genesys-image:latest
fi

read -p $'1. Configuração do repositório git do Genesys
..............................................

Digite a URL do repositório git que será utilizado
(entrada vazia para usar o repositório padrão)\n> ' input_git_repo

if [ -z "$input_git_repo" ]
then
      # Usar repositório padrão

      clone_command=${default_git_repo}
      read -p $'\nDeseja atualizar o repositório padrão (s/N)?\n> ' input_update_repo
      
      if [ "$input_update_repo" == "s" ]; then
        # Atualizar repositório padrão
        docker rm genesys-container && docker run -it --name genesys-container -e clone_command=$clone_command genesys-image ./clone-repo.sh
        docker ps
        handle_save
      else
        # Fazer pull do repositório padrão
        echo "dummy"
        # docker pull genesys-image
      fi
      
else
      # Repositório personalizado
      read -p $'\nDigite a branch:\n> ' input_git_branch
      clone_command=--branch ${input_git_branch} ${input_git_repo}
      
      docker rm genesys-container
      docker run -it --name genesys-container -e clone_command=$clone_command genesys-image ./clone-repo.sh
      handle_save
fi


read -p "
2. Menu: O que deseja executar?
..............................................
1. Genesys GUI
2. Genesys Shell
3. IDE do Genesys (QtCreator)
4. VSCode
> " input

case "$input" in  # TODO: Fazer um loop aqui
        "1")
        command=/home/Genesys-Simulator/GenesysQtGUI
        run_genesys
        ;;       
        "2")
        command=/home/Genesys-Simulator/GenesysShell
        run_genesys
        ;;
        "3")
        command=qtcreator
        run_genesys
        ;; 
        "4")
        command=vscode
        run_genesys
        ;; 
        *)
        echo -e "\nOpção inválida."
        ;;
esac

echo -e "\nSalvando imagem a partir do container..."
handle_save
