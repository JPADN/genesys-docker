# Genesys-Simulator
Dockerização do ambiente de desenvolvimento para o simulador Genesys.

# Docker
Docker é uma poderosa plataforma para desenvolvimento, compartilhamento e execução de aplicações. Ela nos oferece uma forma de empacotar aplicações e suas dependências em container leves e portáveis. Esses containers podem ser executados consistentemente em diferentes ambientes, desde de o laptop do desenvolvedor até um server de produção, garantindo que a aplicação se comporte da mesma maneira em qualquer lugar.

# X Window System 11
O protocolo se trata de um sistema de janelas por rede para sistemas UNIX, criado em 1980 o protocolo tem como objetivo permitir que um cliente e um servidor possam abrir seções interativas por meio de janelas GUI, em que o cliente pode executar um processo e o servidor pode abrir a janela do processo e interajir com o mesmo por meio dos seus dispositivos de entrada. Atualmente, o X11 vem empacotado com a maioria das distribuicoes Linux.

# Set up e execução
Antes de subir o container certifique-se de que o X11 está instalado na máquina hospedeira. Você pode executar o comando abaixo para certificar que o pacote está presente:

```
dpkg -l | grep xorg
```

Para sistemas UNIX basta que o xorg esteja instalado, juntamente com o xauth e executar o script start_container.sh. Em sistemas windows será necessario instalar o Windows Subsystem for Linux (WSL). Em uma seção Powershell administrador, execute o comando:

```
wsl --install
```

Ápos a instalação comandos docker executados em secao WSL serão processados pelo Docker engine da máquina host e poderão ser visualizados na interface Docker Desktop.
Assim como para o container para Linux é necessário montar o volume do socket X11 do Ubuntu WSL com o container. Os comandos disponibilizados no script docker-genesys.sh são válidos para execucao no WSL, contudo como os sockets X11 do WSL estão em volumes especiais no windows, os containers não irão funcionar como esperado. Para iniciar um container no windows basta seguir os passos abaixo:
![install_wsl](https://github.com/Egamik/Genesys-Simulator/assets/44400533/3a9aae4e-20fb-494b-974d-6c65ee0d7286)
Legenda: instalação do WSL no Powershell

![file_explorer](https://github.com/Egamik/Genesys-Simulator/assets/44400533/e3cc6794-aaf6-4e0f-a5fe-4fa26e131d6d)

![wsl_file_location](https://github.com/Egamik/Genesys-Simulator/assets/44400533/4e512553-027f-41c9-bc3e-bd25fbf2ae8a)
Legenda: Caminho do volume a ser montado durante inicialização do container

![volumes](https://github.com/Egamik/Genesys-Simulator/assets/44400533/615a86ba-4a3a-4640-82dc-9b696647b59c)
Legenda: Montagem do volume da pasta dentro do WSL para pasta do container

OBS: Containers docker não têm seus contextos salvos apos o termino da execucao, se voce fez alteracoes no container e que manter as modificacoes ou salve o container como uma nova imagem, ou não remova o container.

## Executando outros comandos no container
Por padrão, o container irá executar o comando declarado na Dockerfile durante a build da imagem e irá parar de executar com a morte do processo, para executar outros comandos sob o mesmo container basta reiniciar o contaier e executar um comando:

```
docker start container-name

docker exec -it container-name command
```

# Script
Além dos containers foi disponibilizado um script para a manutenção e disponibilização de imagens e containers.

## build
Essa função irá montar a imagem da interface gráfica do Genesys com base na branch do repositório em que ele foi executado, após montar a imagem ele irá também gerar um arquivo '.tar' dessa imagem, que será utilizado para gerar um segundo arquivo compactado contendo a imagem e um script para sua inicialização. A ideia é que ao rodar esse script você terá como retorno um pacote capaz de inicializar a interface gráfica do Genesys em qualquer máquina que possua o docker instalado.

## run
Esse script faz a inicialização do container da interface gráfica do Genesys. Basicamente ele necessita da imagem compactada do Genesys para carregar essa imagem usando o docker e inicializá-la como deve ser feita.

## load
Essa função carrega uma imagem genesys-sim.tar para a docker engine.

## save
Essa função commita um container como uma imagem nova, a imagem será nomeada genesys-sim.

# Sugestões

## Integração Contínua
É possível utilizar runners, como do gitlab por exemplo, para automatizar a atualização das imagens do projeto. Eles iriam executar os scripts já existentes para buildar e disponibilizar as imagens, toda vez que a branch main fosse atualizada, mantendo assim a imagem sempre na versão mais atualizada do repositório.

## Registro de container
É possível utilizar serviços de registro de container, como o próprio Docker HUB ou outros, para se disponibilizar as imagens do projeto. A maioria dos registros são pagos, ou bloqueiam algumas funcionalidades através de pagamentos, entretando eles oferecem funções como versionamento de imagens, o que permitiria um usuário baixar qualquer versão do Genesys disponibilizada neste registro. Para acessar as imagens os usuários usariam o próprio docker, informando o url do registro na web (muitas vezes também um usuário e senha de acesso) e fariam download da imagem para seu registro local, tendo apenas que executar o script para sua inicialização localmente. Além disso, utilizando a integração contínua, é possível atualizar as versões das imagens no registro automaticamente.
