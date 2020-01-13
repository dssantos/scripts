#!/bin/bash
# Habilita o tecla AltGr para uso de caracteres Latinos (ç á à ã â) em teclados do Padrão Americano (US International)

echo "Acentos e cedilha:"
echo "0 - Desativar"
echo "1 - Ativar"
read -p "Digite 0 ou 1: " input

case $input in
	0* ) setxkbmap us; echo "Desativado!"; sleep 5;;
	1* ) setxkbmap -layout us -variant altgr-intl -option nodeadkeys; 
		echo -e "
Ativado! Exemplos de uso:\n
 ç  =>  AltGr + ,
 á  =>  AltGr + a
 à  =>  AltGr + \`  a
 ã  =>  AltGr + Shift + ~   a
 â  =>  AltGr + ^   a";
		sleep 10;;
	* ) echo "Opção inválida. Nada foi feito."; sleep 5;;
esac
