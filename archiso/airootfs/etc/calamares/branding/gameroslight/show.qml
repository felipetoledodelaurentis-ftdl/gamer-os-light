/* Gamer OS Light - slides exibidos durante a instalacao */
import QtQuick 2.15
import calamares.slideshow 1.0

Presentation {
    id: presentation

    function nextSlide() { presentation.goToNextSlide(); }

    Timer {
        id: advanceTimer
        interval: 7000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    Rectangle { anchors.fill: parent; color: "#0B0D1A"; z: -1 }

    Slide {
        Image {
            id: logo1
            source: "logo.png"
            width: 140; height: 140
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top; anchors.topMargin: 30
        }
        Text {
            anchors.top: logo1.bottom; anchors.topMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#E8EAFF"; font.pixelSize: 20
            text: "<b>Bem-vindo ao Gamer OS Light</b><br/><br/>Leve, rápido e feito para jogar."
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#E8EAFF"; font.pixelSize: 18
            text: "<b style='color:#00E5FF'>Steam pronta para usar</b><br/><br/>Jogos de Windows rodam pelo Proton. Abra a Steam, entre na sua conta e instale seus jogos."
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#E8EAFF"; font.pixelSize: 18
            text: "<b style='color:#8B5CF6'>Central Gamer</b><br/><br/>Veja FPS, processador e memória em tempo real dentro dos jogos e escolha o modo de energia: Economia, Normal ou Alta performance."
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#E8EAFF"; font.pixelSize: 18
            text: "<b style='color:#22C55E'>Controles de Xbox e PlayStation</b><br/><br/>Conecte pelo cabo USB ou pareie pelo Bluetooth. Funciona direto, sem instalar nada."
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#E8EAFF"; font.pixelSize: 18
            text: "<b style='color:#EC4899'>Tudo para o dia a dia</b><br/><br/>Firefox, LibreOffice (textos, planilhas e apresentações), player de vídeo e loja de aplicativos."
        }
    }

    function onActivate() { presentation.currentSlide = 0; }
    function onLeave() { }
}
