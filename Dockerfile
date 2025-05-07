FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends locales && echo "LANG=C.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get install -y ubuntu-gnome-desktop gnome-panel metacity tigervnc-standalone-server tilix wget
RUN apt-get install -y novnc python3-websockify python3-numpy 
RUN openssl req -new -subj "/C=JP" -x509 -days 3650 -nodes -out novnc.pem -keyout novnc.pem
RUN cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

EXPOSE 5901
EXPOSE 5902

RUN touch ~/.Xresources
RUN touch ~/.Xauthority
RUN mkdir ~/Desktop/
RUN mkdir ~/.vnc/
RUN echo "123456" | vncpasswd -f > ~/.vnc/passwd
RUN echo "#!/bin/sh\n" \
        "\n" \
        "export XKL_XMODMAP_DISABLE=1\n" \
        "unset SESSION_MANAGER\n" \
        "unset DBUS_SESSION_BUS_ADDRESS\n" \
        "\n" \
        "export XKL_XMODMAP_DISABLE=1\n" \
        "export XDG_CURRENT_DESKTOP=\"GNOME-Flashback:Unity\"\n" \
        "export XDG_MENU_PREFIX=\"gnome-flashback-\"\n" \
        "\n" \
        "[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup\n" \
        "[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources\n" \
        "xsetroot -solid grey\n" \
        "vncconfig -iconic &\n" \
        "\n" \
        "gnome-session --session=gnome-flashback-metacity --disable-acceleration-check &\n" \
        "gnome-panel &\n" \
        "metacity &\n" > ~/.vnc/xstartup
RUN echo "#!/bin/sh\n" \
        "vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE \n" \
        "websockify -D --web=/usr/share/novnc/ --cert=/home/ubuntu/novnc.pem 5902 localhost:5901 \n" \
        "/bin/bash\n" > /.entry
RUN chmod a+x /.entry

RUN wget https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.i686
RUN chmod a+x ttyd.i686

CMD ./.entry && ./ttyd.i686 -p 8006 -W /usr/bin/bash





#sudo docker build -t ubuntu-gui .
#sudo docker run -d -p 8006:5902 --name ubuntu-gui ubuntu-gui
