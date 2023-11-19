#!/bin/bash
$command

# Salvar o trabalho
echo -e "\nNão se esqueça de salvar seu trabalho. Commite suas alterações e faça o push.\n\n"

read -p $'Gostaria de acessar o terminal antes de sair (s/N)?\n> ' input_access_terminal

if [ "$input_access_terminal" == "s" ]; then
  cd /home/Genesys-Simulator && bash     
fi

