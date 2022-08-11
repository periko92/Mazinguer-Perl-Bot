#!/usr/bin/perl

use IO::Socket;

######################################################################
#								     #
#  MAZINGUER IRC Service v2.1.1.perl02 by JeNdArK    27 - 12 - 2003  #
#								     #
######################################################################

# Adaptación del MAZINGUER IRC Service v2.1.1(5)
# programado por Ni[0 en mIRC Scripting
# http://www.ansii.net

# ~ Consideraciones de la versión ~

# - Se respetan casi todos los comandos del MAZINGUER en mIRC Scripting
# - Se añaden comandos auxiliares del bot CeNTRaL de los SaBBaT
#   (ver http://www.sf.net/projects/sabbat/)

# Pogramado tomando diversos ejemplos de tutoriales de Perl
# por JeNdArK el 27-12-2003
# Finalidad: Didáctica (algo he aprendido, al menos yo ^_^)

# Por cierto, no cambies 2 cosas y quites los créditos por favor
# si cambias algo, agrégate como autor a los creditos actuales :P
# Para comentarios, dudas, sugerencias: chaguix@terra.es

# P.D: Seguro que había 1000 formas + fáciles de hacerlo, ¿he dicho que no sabía Perl?
#      Si Finisher si, esto es Perl, es un lenguaje de programación... verdad? xD

# A JUGAAAAAAAAAAAAAAAAAARRRRRRRRRRRRRRRRRR

principio:

admins();

# COMIENZA CONFIGURACIÓN # (Cambiais lo que va entre comillas)

my $hub = "muno.no-ip.org"; # <--- Ip del servidor al que linkais.
my $puerto = "4400"; # <--- Puerto por el que conectais.
my $nodopass = "devel"; # <--- Contraseña de acceso.
my $nododesc = "Servidor devel en Perl"; # <--- Descripción del servidor virtual
my $nick = "Mazi_Perl"; # <--- Nick del bot de servicio.
my $ident = "Perl"; # <--- Ident del bot de servicio.
my $canaldebug = "#devels"; # <--- Canal donde el bot hará debug.
my $host = "perl.ansii.net"; # <--- Host que tendrá el bot.
my $nickdesc = "pruebas en Perl"; # <--- Descripción del nick (Realname).
my $root = "jendark"; # <--- Nick del ROOT del bot > En minúsculas <
my $nodoname = "sabbat.ansii.net"; # <--- Nombre del nodo que alojará el bot.
my $network = "ansii.net"; # <--- Nombre de la red.
my $redmail = 'chaguix@terra.es'; # <--- Vuestro email de contacto.

# FIN DE CONFIGURACIÓN #

my $numerico = num();
my $nicknum = "${numerico}AA";
my $simboloarroba = '@';
my $dollar = '$';
my $nodo = IO::Socket::INET->new( 
		Proto     => "tcp",
                PeerAddr  => $hub,
                PeerPort  => $puerto,
                );

conecta();

while (<$nodo>)
{
	my @datos = split(" ", $_);
	$datos[0]=~ s/://;
	$datos[2]=~ s/://;
	$datos[3]=~ s/://;
	# print "$_\n";
	# Nos ahorramos ver los pings por la consola que son un coñazo	

	if (($datos[1] ne "PING") && ($datos[2] ne ":$hub"))
	{ 
		print "@datos\n";
		print "\n";
	}

	# Reconexion si hay NUMERIC collision

	if (($datos[0] eq "ERROR") && ($datos[0] eq "collision")) { conecta() }

	# Respuesta al Ping y End of Burst

	if ($datos[1] eq "PING")
	{
		print $nodo "Z $hub :$nodoname\n";
	}
	if (($datos[0] ne "$numerico") && ($datos[1] eq "END_OF_BURST") && ($varEB ne "ok"))
	{
		print $nodo "$numerico EB\n";
		my $varEB = "ok";
	}
	if (($datos[0] ne "$numerico") && ($datos[1] eq "EOB_ACK") && ($varEA ne "ok"))
	{
		print $nodo "$numerico EA\n";
		my $varEA = "ok";
	}

	# Mirando la BDD

	if (($datos[1] eq "DB") && ($datos[2] eq "*") && ($datos[4] eq "J"))
	{
		print $nodo "$numerico @datos[1..6]\n";
		$tabla{$datos[6]} = $datos[5];
	}
	if (($datos[1] eq "DB") && ($datos[2] eq "*") && ($datos[4] ne "J"))
	{
		print $nodo "$numerico @datos[1..6]\n";
		$tabla{$datos[4]} = $datos[3];
	}

	# Conecta un usuario

	if (($datos[9]) && ($datos[1] eq "NICK"))
	{
		$datos[10]=~ s/://;
		if ($debug eq "ok") { botdebug("3Entra12 $datos[2] [ $datos[6] ] Modos:12 $datos[7] Realname:12 @datos[10..$#datos] ") }
		$datos[2] =~ tr/A-Z/a-z/; # pasamos el nick a minúsculas

		$ip{$datos[2]} = $datos[6]; # ipnick = ip

		$trio{$datos[2]} = $datos[9]; # trionick = trio

		$nick{$datos[9]} = $datos[2]; # nicktrio = nick

		if ($datos[7] =~ /o/)
		{
			if ($debug eq "ok") { print $nodo ":$nick P $canaldebug :12$datos[2] es ahora un 12IRCOP.\n" }
			$ircop{$datos[2]} = "ok";
		}
		if ($datos[7] =~ /rh/)
		{
			if ($debug eq "ok") { print $nodo ":$nick P $canaldebug :12$datos[2] es ahora un 12OPER.\n" }
			$oper{$datos[2]} = "ok";
		}
		open(ENTRADA, "entrada.txt");
		while($entrada = <ENTRADA>) { print $nodo ":$nick P $trio{$datos[2]} :$entrada\n"; }
		close(ENTRADA);
	}

	# Desconecta un usuario

	if ($datos[1] eq "QUIT")
	{
		if ($debug eq "ok") { botdebug("4Sale 12$datos[0] [ $ip{$datos[0]} ] Mensaje:12 @datos[4..$#datos]") }	
		$datos[0] =~ tr/A-Z/a-z/; # pasamos el nick a minúsculas
		undef $ircop{$datos[0]};
		undef $oper{$datos[0]};
		undef $nick{$trio{$datos[0]}};
		undef $ip{$datos[0]};
		undef $trio{$datos[0]};
	}
	if ($datos[1] eq "KILL")
	{
		if ($debug eq "ok") { botdebug("4Sale 12$nick{$datos[2]} [ $ip{$nick{$datos[2]}} ]") }
		undef $ircop{$nick{$datos[2]}};
		undef $oper{$nick{$datos[2]}};
		undef $ip{$nick{$datos[2]}};
		undef $trio{$nick{$datos[2]}};
		undef $nick{$datos[2]};
	}

	# Debug de OPERs, IRCOPs y XMODE

	if (($datos[1] eq "MODE") && ($datos[3] =~ /o/) && (!$datos[4]))
	{
		$datos[2] =~ tr/A-Z/a-z/; # pasamos el nick a minúsculas
		if (!$ircop{$datos[2]})
		{
		if ($debug eq "ok") { botdebug("12$datos[2] es ahora un 12IRCOP.") }
		$ircop{$datos[2]} = "ok";
		}
		else { undef $ircop{$datos[2]} }
	}
	if (($datos[1] eq "MODE") && ($datos[3] =~ /rh/) && (!$datos[4]))
	{
		$datos[2] =~ tr/A-Z/a-z/; # pasamos el nick a minúsculas
		if (!$oper{$datos[2]})
		{
		if ($debug eq "ok") { botdebug("12$datos[2] es ahora un 12OPER.") }
		$oper{$datos[2]} = "ok";
		}
		else { undef $oper{$datos[2]} }
	}
	if (($datos[1] eq "MODE") && ($datos[3] =~ /x/))
	{
		if ($debug eq "ok") { botdebug("12$datos[0] ha usado 12$datos[3] en 12$datos[2].") }
	}

	# Cambio de nick

	if ((!$datos[4]) && ($datos[1] eq "NICK")) # trio NICK nuevonick
	{
		$datos[2] =~ tr/A-Z/a-z/; # pasamos el nuevo nick a minúsculas
		if ($oper{$nick{$datos[0]}})
		{
		undef $oper{$nick{$datos[0]}};
		$oper{$datos[2]} = "ok";
		}
		if ($ircop{$nick{$datos[0]}})
		{
		undef $ircop{$nick{$datos[0]}};
		$ircop{$datos[2]} = "ok";
		}

		$ip{$datos[2]} = $ip{$nick{$datos[0]}}; # ip{nuevonick} = ip{viejonick} -> viejonick = nick{viejotrio}
		undef $ip{$nick{$datos[0]}};

		$trio{$datos[2]} = $datos[0]; # trio{nuevonick} = trio
		undef $trio{$nick{$datos[0]}};

		$nick{$datos[0]} = $datos[2]; # nick{trio} = nuevonick -> Reasignamos el trio
	}

	# Chorradas varias

	if ($datos[1] eq "TIME")
	{
		$datos[0] =~ tr/A-Z/a-z/; # pasamos el nick a minúsculas
		print $nodo "$numerico 391 $trio{$datos[0]} :". localtime() ."\n";		
	}
	if ($datos[1] eq "VERSION")
	{
		$datos[0] =~ tr/A-Z/a-z/; # pasamos el nick a minúsculas
		print $nodo "$numerico 351 $trio{$datos[0]} :MAZINGUER IRC Service v2.1.1.perl02 27 - 12 - 2003\n";
	}
	if ($datos[1] eq "ADMIN")
	{
		$datos[0] =~ tr/A-Z/a-z/; # pasamos el nick a minúsculas
		print $nodo "$numerico 256 $trio{$datos[0]} :Información administrativa de $nodoname\n";
		print $nodo "$numerico 257 $trio{$datos[0]} :Servidor de servicios auxiliares - $network\n";
		print $nodo "$numerico 258 $trio{$datos[0]} :$admin\n";
		print $nodo "$numerico 259 $trio{$datos[0]} :$redmail\n";		
	}

	# COMANDOS !!!!!!!!!!!!!!!

	$datos[0] =~ tr/A-Z/a-z/; # pasamos el nick a minúsculas
	$datos[3] =~ tr/A-Z/a-z/;
	$datos[4] =~ tr/A-Z/a-z/;
	$datos[5] =~ tr/A-Z/a-z/;

	if (($datos[1] eq "PRIVMSG") && ($datos[2] eq "$nicknum"))
	{
		# Comando CREDITOS (El burro delante)

		if (($datos[3] eq "credits") || ($datos[3] eq "creditos"))
		{
			botpriv("$trio{$datos[0]} :12$nick Servicio de soporte para IRCu");
			botpriv("$trio{$datos[0]} :");
			botpriv("$trio{$datos[0]} :Release:  12v2.1.1.perl02 27-12-2003");
			botpriv("$trio{$datos[0]} :Autor: 4JeNdArK");
			botpriv("$trio{$datos[0]} :Betatester: 4Ni[0");
			botpriv("$trio{$datos[0]} :URL:12 http://www.ansii.net/");
			botpriv("$trio{$datos[0]} :Descripcion: Servicios realizados para12 ansii.net IRC Network");
			botpriv("$trio{$datos[0]} :para tareas de mantenimiento de la red.");
			botpriv("$trio{$datos[0]} :Se agradece a 12Verónica y 12Ni[0 su colaboración asi como a");
			botpriv("$trio{$datos[0]} :todos aquellos que confiaron en esto, betatesters y operadores, que han");
			botpriv("$trio{$datos[0]} :colaborado en las pruebas aportando ideas.");
			botpriv("$trio{$datos[0]} :Saludos!! Para comentarios, sugerencias, Bugs, etc... mandar e-mail a:");
			botpriv("$trio{$datos[0]} :12chaguix@terra.es");
			botpriv("$trio{$datos[0]} :");
		}

		# Comando HELP

		if (($datos[3] eq "help") && (($oper{$datos[0]}) || ($admin{$datos[0]})))
		{
			if (!$datos[4]) 
			{
				
				botpriv("$trio{$datos[0]} :12$nick Servicio de soporte. v2.1.1.perl02");
				botpriv("$trio{$datos[0]} :");
				botpriv("$trio{$datos[0]} :Comandos de 12$nick para 12OPERistradores:");
				botpriv("$trio{$datos[0]} :");
				botpriv("$trio{$datos[0]} :12OP DEOP KICK MODE INVITE ");
				botpriv("$trio{$datos[0]} :12CLEARMODES KILL VHOST GLINE");
				botpriv("$trio{$datos[0]} :12GLINEIP UNGLINE SETTIME");
				botpriv("$trio{$datos[0]} :12MASSOP MASSDEOP MASSKICK");
				botpriv("$trio{$datos[0]} :12JOIN PART GLOBAL");
				botpriv("$trio{$datos[0]} :");
				if ($admin{$datos[0]})
				{
					botpriv("$trio{$datos[0]} :Comandos de 12$nick para 12ADMINistradores:");
					botpriv("$trio{$datos[0]} :");
					botpriv("$trio{$datos[0]} :12DEBUG RENAME RAW SQUIT");
					botpriv("$trio{$datos[0]} :12MASSKILL MASSGLINE ENTRYMSG");
					botpriv("$trio{$datos[0]} :12JUPE SHUTDOWN RESTART");
					botpriv("$trio{$datos[0]} :12ADMIN ADDCHANNEL DELCHANNEL");
					botpriv("$trio{$datos[0]} :");
				}
				botpriv("$trio{$datos[0]} :Para +info 12/msg $nick HELP <COMANDO>");
				botpriv("$trio{$datos[0]} :");
			}
			if ($datos[4] eq "op")
			{
				botpriv("$trio{$datos[0]} :12OP Da @ en un canal especifico a un usuario.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick OP <#canal> <nick>");
			}
			if ($datos[4] eq "deop")
			{
				botpriv("$trio{$datos[0]} :12DEOP Quita @ en un canal especifico a un usuario.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick DEOP <#canal> <nick>");
			}
			if ($datos[4] eq "kick")
			{
				botpriv("$trio{$datos[0]} :12KICK Expulsa a un usuario de un canal.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick KICK <#canal> <nick> <motivo>");
			}
			if ($datos[4] eq "kill")
			{
				botpriv("$trio{$datos[0]} :12KILL Expulsa a un usuario de la red.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick KILL <nick> <motivo>");
			}
			if ($datos[4] eq "mode")
			{
				botpriv("$trio{$datos[0]} :12MODE Cambia los modos de un canal.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick MODE <#canal> <+/-modos>");
			}
			if ($datos[4] eq "clearmodes")
			{
				botpriv("$trio{$datos[0]} :12CLEARMODES Quita todos los modos de un canal.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick CLEARMODES <#canal>");
			}
			if ($datos[4] eq "settime")
			{
				botpriv("$trio{$datos[0]} :12SETTIME Sincroniza el servidor.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick SETTIME");
			}
			if ($datos[4] eq "gline")
			{
				botpriv("$trio{$datos[0]} :12GLINE Expulsa de la red a un usuario.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick GLINE <nick> <tiempo> <motivo>");
			}
			if ($datos[4] eq "glineip")
			{
				botpriv("$trio{$datos[0]} :12GLINEIP Expulsa de la red a un ident${simboloarroba}host.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick GLINEIP <ident${simboloarroba}host> <tiempo> <motivo>");
			}
			if ($datos[4] eq "ungline")
			{
				botpriv("$trio{$datos[0]} :12UNGLINE Elimina el Gline especificado.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick UNGLINE <ident${simboloarroba}host>");
			}
			if ($datos[4] eq "massdeop")
			{
				botpriv("$trio{$datos[0]} :12MASSDEOP Deopea a todos los usuarios de un canal.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick MASSDEOP <#canal>");
			}
			if ($datos[4] eq "massop")
			{
				botpriv("$trio{$datos[0]} :12MASSOP Da @ a todos los usuarios de un canal.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick MASSOP <#canal>");
			}
			if ($datos[4] eq "masskick")
			{
				botpriv("$trio{$datos[0]} :12MASSKICK Expulsa a todos los usuarios de un canal.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick MASSKICK <#canal>");
			}
			if ($datos[4] eq "join")
			{
				botpriv("$trio{$datos[0]} :12JOIN Mete a 12$nick en un canal..");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick JOIN <#canal>");
			}
			if ($datos[4] eq "part")
			{
				botpriv("$trio{$datos[0]} :12PART Saca a 12$nick de un canal.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick PART <#canal>");
			}
			if ($datos[4] eq "invite")
			{
				botpriv("$trio{$datos[0]} :12INVITE Te invita a un canal.");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick INVITE <#canal>");
			}
			if ($datos[4] eq "global")
			{
				botpriv("$trio{$datos[0]} :12GLOBAL Manda un mensaje global (Si se especifica un nick");
				botpriv("$trio{$datos[0]} :precedido del signo + se enviará bajo dicho nick).");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick GLOBAL <+nick> <mensaje>");
			}
			if ($datos[4] eq "vhost")
			{
				botpriv("$trio{$datos[0]} :12VHOST Asigna un host virtual a un usuario (requiere BDD).");
				botpriv("$trio{$datos[0]} :4NOTA: Se debe elegir entre la tabla '4v' y la '4w'");
				botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick VHOST <add/del> <v/w> <nick> <vhost>");
			}
			if ($admin{$datos[0]})
			{
				if ($datos[4] eq "debug")
				{
					botpriv("$trio{$datos[0]} :12DEBUG Activa o desactiva el modo 12DEBUG.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick DEBUG <ON/OFF>");
				}
				if ($datos[4] eq "shutdown")
				{
					botpriv("$trio{$datos[0]} :12SHUTDOWN Desconecta a 12$nick.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick SHUTDOWN");
				}
				if ($datos[4] eq "masskill")
				{
					botpriv("$trio{$datos[0]} :12MASSKILL Expulsa de la red a los usuarios de un canal.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick MASSKILL <#canal>");
				}
				if ($datos[4] eq "massgline")
				{
					botpriv("$trio{$datos[0]} :12MASSGLINE Expulsa de la red a los usuarios de un canal (5min).");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick MASSGLINE <#canal>");
				}
				if ($datos[4] eq "rename")
				{
					botpriv("$trio{$datos[0]} :12RENAME Cambia el nick a un usuario por otro aleatorio.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick RENAME <nick>");
				}
				if ($datos[4] eq "raw")
				{
					botpriv("$trio{$datos[0]} :12RAW Manda un RAW al servidor.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick RAW <secuencia>");
				}
				if ($datos[4] eq "squit")
				{
					botpriv("$trio{$datos[0]} :12SQUIT Expulsa un servidor de la red.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick SQUIT <servidor>");
				}
				if ($datos[4] eq "jupe")
				{
					botpriv("$trio{$datos[0]} :12JUPE Impide la entrada de un servidor a la red.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick JUPE <servidor> <motivo>");
				}	
				if ($datos[4] eq "restart")
				{
					botpriv("$trio{$datos[0]} :12RESTART reinicializa a 12$nick.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick RESTART");
				}
				if ($datos[4] eq "admin")
				{
					botpriv("$trio{$datos[0]} :12ADMIN modifica los administradores de 12$nick.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick ADMIN <add/del/list> <nick>");
				}
				if ($datos[4] eq "addchannel")
				{
					botpriv("$trio{$datos[0]} :12ADDCHANNEL agrega un canal como autojoin.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick ADDCHANNEL <#canal>");
				}
				if ($datos[4] eq "delchannel")
				{
					botpriv("$trio{$datos[0]} :12DELCHANNEL elimina un canal como autojoin.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick DELCHANNEL <#canal>");
				}
				if ($datos[4] eq "entrymsg")
				{
					botpriv("$trio{$datos[0]} :12ENTRYMSG Graba un mensaje de entrada que se");
					botpriv("$trio{$datos[0]} :mostrara a todo aquel que entre en la red.");
					botpriv("$trio{$datos[0]} :Sintaxis: 12/msg $nick ENTRYMSG <mensaje>");
				}
			}
		}

		# Comandos para OPERadores

		if (($oper{$datos[0]}) || ($admin{$datos[0]}))
		{

			# Comando OP

			if ($datos[3] eq "op")
			{
				if (!$datos[5])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick OP <#CANAL> <NICK>") }
				elsif (!$trio{$datos[5]}) { botpriv("$trio{$datos[0]} :4ERROR!! El nick especificado debe encontrarse conectado.") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }
				else
				{
					print $nodo ":$nick M $datos[4] +o $trio{$datos[5]} \n";
					if ($debug eq "ok") { botdebug("Comando 12OP ejecutado por 12$datos[0] sobre 12$datos[5]") }
				}
			}

			# Comando DEOP

			if ($datos[3] eq "deop")
			{
				if (!$datos[5])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick DEOP <#CANAL> <NICK>") }
				elsif (!$trio{$datos[5]}) { botpriv("$trio{$datos[0]} :4ERROR!! El nick especificado debe encontrarse conectado.") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }
				else {
					print $nodo ":$nick M $datos[4] -o $trio{$datos[5]} \n";
					if ($debug eq "ok") { botdebug("Comando 12DEOP ejecutado por 12$datos[0] sobre 12$datos[5]") }
				}
			}

			# Comando KICK

			if ($datos[3] eq "kick")
			{
				if (!$datos[6])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick KICK <#CANAL> <NICK> <MOTIVO>") }
				elsif (!$trio{$datos[5]}) { botpriv("$trio{$datos[0]} :4ERROR!! El nick especificado debe encontrarse conectado.") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }
				else
				{
					print $nodo ":$nick KICK $datos[4] $trio{$datos[5]} @datos[6..$#datos]\n";
					if ($debug eq "ok") { botdebug("Comando 12KICK ejecutado por 12$datos[0] sobre 12$datos[5] en 12$datos[4]. Motivo: 4@datos[6..$#datos]") }
				}
			}

			# Comando KILL

			if ($datos[3] eq "kill")
			{
				if (!$datos[5])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick KILL <NICK> <MOTIVO>") }
				elsif (!$trio{$datos[4]}) { botpriv("$trio{$datos[0]} :4ERROR!! El nick especificado debe encontrarse conectado.") }
				else {
				print $nodo ":$nick KILL $trio{$datos[4]} :@datos[5..$#datos]\n";
				if ($debug eq "ok") { botdebug("Comando 12KILL ejecutado por 12$datos[0] sobre 12$datos[4]. Motivo: 4@datos[5..$#datos]") }
				}
			}

			# Comando MODE
	
			if ($datos[3] eq "mode")
			{
				if (!$datos[5])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick MODE <#CANAL> <+/-MODOS>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }
				else
				{
					print $nodo ":$nick M $datos[4] @datos[5..$#datos]\n";
					if ($debug eq "ok") { botdebug("Comando 12MODE ejecutado por 12$datos[0] en 12$datos[4] -> 4$datos[5]") }
				}
			}

			# Comando CLEARMODES

			if ($datos[3] eq "clearmodes")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick CLEARMODES <#CANAL>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }
				else 
				{
					print $nodo ":$nick M $datos[4] -iklmnpstrRM\n";
					if ($debug eq "ok") { botdebug("Comando 12CLEARMODES ejecutado por 12$datos[0] en 12$datos[4]") }
				}
			}
	
			# Comando SETTIME
	
			if ($datos[3] eq "settime")
			{
				my $ctime = time();
				print $nodo "$numerico SETTIME $ctime\n";
				if ($debug eq "ok") { botdebug("12$datos[0] ejecuta 12SETTIME") }
			}

			# Comando GLINE

			if ($datos[3] eq "gline")
			{
				if (!$datos[5])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick GLINE <NICK> <TIEMPO EN SEGS> <MOTIVO>") }
				elsif (!$trio{$datos[4]}) { botpriv("$trio{$datos[0]} :4ERROR!! El nick especificado debe encontrarse conectado.") }
				else
				{
					print $nodo "$numerico GL * *${simboloarroba}$ip{$datos[4]} +$datos[5] :@datos[6..$#datos]\n";
					if ($debug eq "ok") { botdebug("Comando 12GLINE ejecutado por 12$datos[0] sobre 12$datos[4]. Motivo: 4@datos[6..$#datos]") }
				}
			}

			# Comando GLINEIP

			if ($datos[3] eq "glineip")
			{
				if (!$datos[5])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick GLINEIP <IDENT${simboloarroba}HOST> <TIEMPO EN SEGS> <MOTIVO> ") }
				else {
				print $nodo "$numerico GL * +$datos[4] +$datos[5] :@datos[6..$#datos]\n";
				if ($debug eq "ok") { botdebug("Comando 12GLINEIP ejecutado por 12$datos[0] sobre 4$datos[4]. Motivo: 4@datos[6..$#datos]") }
				}
			}

			# Comando UNGLINE

			if ($datos[3] eq "ungline")
			{
				if (!$datos[5])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick UNGLINE <IDENT@HOST>") }
				else
				{
				print $nodo "$numerico GL * -$datos[4] +$datos[5] \n";
				if ($debug eq "ok") { botdebug("Comando 12UNGLINE ejecutado por 12$datos[0] sobre 4$datos[4].") }
				}
			}

			# Comando MASSDEOP
	
			if ($datos[3] eq "massdeop")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick MASSDEOP <#CANAL>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else
				{
					undef $deop{$datos[4]};
					undef $kick{$datos[4]};
					undef $op{$datos[4]};
					undef $gline{$datos[4]};
					undef $kill{$datos[4]};
					$deop{$datos[4]} = "ok";
					print $nodo ":$nick WHO $datos[4]\n";
					if ($debug eq "ok") { botdebug("Comando 12MASSDEOP ejecutado por 12$datos[0] en 4$datos[4].") }
				}
			}

			# Comando MASSOP
	
			if ($datos[3] eq "massop")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick MASSOP <#CANAL>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else 
				{
					undef $deop{$datos[4]};
					undef $kick{$datos[4]};
					undef $op{$datos[4]};
					undef $gline{$datos[4]};
					undef $kill{$datos[4]};
					$op{$datos[4]} = "ok";
					print $nodo ":$nick WHO $datos[4]\n";
					if ($debug eq "ok") { botdebug("Comando 12MASSOP ejecutado por 12$datos[0] en 4$datos[4].") }
				}
			}

			# Comando MASSKICK

			if ($datos[3] eq "masskick")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick MASSKICK <#CANAL>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else 
				{
					undef $deop{$datos[4]};
					undef $kick{$datos[4]};
					undef $op{$datos[4]};
					undef $gline{$datos[4]};
					undef $kill{$datos[4]};
					$kick{$datos[4]} = "ok";
					print $nodo ":$nick WHO $datos[4]\n";
					if ($debug eq "ok") { botdebug("Comando 12MASSKICK ejecutado por 12$datos[0] en 4$datos[4].") }
				}
			}

			# Comando JOIN
	
			if ($datos[3] eq "join")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick JOIN <#CANAL>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else
				{
					print $nodo ":$nick JOIN $datos[4]\n";
					if ($debug eq "ok") { botdebug("Comando 12JOIN ejecutado por 12$datos[0] en 4$datos[4].") }
				}
			}

			# Comando PART

			if ($datos[3] eq "part")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick PART <#CANAL>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else
				{
					print $nodo ":$nick PART $datos[4]\n";
					if ($debug eq "ok") { botdebug("Comando 12PART ejecutado por 12$datos[0] en 4$datos[4].") }
				}
			}
		
			# Comando INVITE

			if ($datos[3] eq "invite")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick INVITE <#CANAL>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else
				{
					print $nodo ":$nick INVITE $datos[0] $datos[4]\n";
					if ($debug eq "ok") { botdebug("Comando 12INVITE ejecutado por 12$datos[0] en 4$datos[4].") }
				}
			}

			# Comando GLOBAL

			if ($datos[3] eq "global")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick GLOBAL <+NICK> <MENSAJE>") }
				elsif (substr($datos[4], 0,1) eq "+")
				{
					my $globalnick = substr($datos[4], 1);
					if ($trio{$globalnick}) { botpriv("$trio{$datos[0]} :4ERROR!! No puedes enviar un global con un nick conectado.") }
 					else
					{
						my $ctime = time();
						my $globalnick = substr($datos[4], 1);
						print $nodo "$numerico N $globalnick 1 $ctime globales globales.$network +diorXBkhgw DDNSca ${numerico}BB :Servicio de globales\n";
						print $nodo ":$globalnick P ${dollar}*.$network :@datos[5..$#datos]\n";
						print $nodo ":$globalnick QUIT :Servicio de globales\n";
						if ($debug eq "ok") { botdebug("Comando 12GLOBAL ejecutado por 12$datos[0] bajo el nick 12$globalnick. Mensaje: 4@datos[5..$#datos].") }
					}
				}			
				else 
				{
					print $nodo ":$nick P ${dollar}*.$network :@datos[4..$#datos]\n";
					if ($debug eq "ok") { botdebug("Comando 12GLOBAL ejecutado por 12$datos[0]. Mensaje: 4@datos[4..$#datos].") }
				}
			}

			# Comando VHOST
	
			if ($datos[3] eq "vhost")
			{
				if (!$datos[7])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick VHOST <ADD/DEL> <V/W> <NICK> <VHOST>") }
				elsif (($datos[5] ne "v") && ($datos[5] ne "w")) { botpriv("$trio{$datos[0]} :4ERROR!! Debes expecificar la tabla 4V o 4W.") }
				elsif ($datos[4] eq "add")
				{
					$tabla{$datos[5]} = ++$tabla{$datos[5]};
					print $nodo "$numerico DB * $tabla{$datos[5]} $datos[5] $datos[6] $datos[7]\n";
					print $nodo "$numerico RENAME $datos[6]\n";
					if ($debug eq "ok") { botdebug("Comando 12VHOST ADD ejecutado por 12$datos[0] sobre 12$datos[6] en tabla 12$datos[5]. Vhost: 4$datos[7].") }
				}
				elsif ($datos[4] eq "del")
				{
					$tabla{$datos[5]} = ++$tabla{$datos[5]};
					print $nodo "$numerico DB * $tabla{$datos[5]} $datos[5] $datos[6]\n";
					print $nodo "$numerico RENAME $datos[6]\n";
					if ($debug eq "ok") { botdebug("Comando 12VHOST DEL ejecutado por 12$datos[0] sobre 12$datos[6] en tabla 12$datos[5].") }
				}
			}
		}

		# Comandos para ADMINistradores

		if ($admin{$datos[0]})
		{

			# Comando RENAME

			if ($datos[3] eq "rename")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick RENAME <NICK>") }
				elsif (!$trio{$datos[4]}) { botpriv("$trio{$datos[0]} :4ERROR!! El nick especificado debe encontrarse conectado.") }
				else
				{
					print $nodo "$numerico RENAME $datos[4]\n";
					if ($debug eq "ok") { botdebug("Comando 12RENAME ejecutado por 12$datos[0] sobre 12$datos[4].") }
				}
			}

			# Comando RAW

			if ($datos[3] eq "raw")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick RAW <SECUENCIA>") }
				else
				{
					print $nodo "$numerico @datos[4..$#datos]\n";
					if ($debug eq "ok") { botdebug("Comando 12RAW ejecutado por 12$datos[0] --> 4@datos[4..$#datos]") }
				}
			}

			# Comando SQUIT

			if ($datos[3] eq "squit")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick SQUIT <SERVIDOR>") }
				else
				{
					print $nodo "$numerico SQ $datos[4] 0 \n";
					if ($debug eq "ok") { botdebug("Comando 12SQUIT ejecutado por 12$datos[0] sobre 4$datos[4]") }
				}
			}

			# Comando JUPE

			if ($datos[3] eq "jupe")
			{
				if (!$datos[5])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick JUPE <SERVIDOR> <MOTIVO>") }
				else
				{
					print $nodo "$numerico SQ $datos[4] 0 \n";
					my $ctime = time();
					my $numjupe = num();
					print $nodo "$numerico SERVER $datos[4] 2 $ctime $ctime P10 $${numjupe}D] :JUPE @datos[5..$#datos]\n";
					if ($debug eq "ok") { botdebug("Comando 12JUPE ejecutado por 12$datos[0] sobre 4$datos[4]. Motivo: 4@datos[5..$#datos]") }
				}
			}

			# Comando MASSKILL

			if ($datos[3] eq "masskill")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick MASSKILL <#CANAL>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else 
				{
					undef $deop{$datos[4]};
					undef $kick{$datos[4]};
					undef $op{$datos[4]};
					undef $gline{$datos[4]};
					undef $kill{$datos[4]};
					$kill{$datos[4]} = "ok";
					print $nodo ":$nick WHO $datos[4]\n";
					if ($debug eq "ok") { botdebug("Comando 12MASSKILL ejecutado por 12$datos[0] en 4$datos[4].") }
				}
			}

			# Comando MASSGLINE

			if ($datos[3] eq "massgline")
			{
				if (!$datos[4])	{ botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick MASSGLINE <#CANAL>") }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else 
				{
					undef $deop{$datos[4]};
					undef $kick{$datos[4]};
					undef $op{$datos[4]};
					undef $gline{$datos[4]};
					undef $kill{$datos[4]};
					$gline{$datos[4]} = "ok";
					print $nodo ":$nick WHO $datos[4]\n";
					if ($debug eq "ok") { botdebug("Comando 12MASSGLINE ejecutado por 12$datos[0] en 4$datos[4].") }
				}
			}

			# Comando DEBUG
	
			if ($datos[3] eq "debug")
			{
				if ($datos[4] eq "on")
				{
					botpriv("$trio{$datos[0]} :Modo DEBUG 4Activado.");
					$debug = "ok";
				}
				if ($datos[4] eq "off")
				{
					botpriv("$trio{$datos[0]} :Modo DEBUG 4Desactivado.");
					undef $debug;
				}
				if (!$datos[4])
				{
					botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick DEBUG <ON/OFF> ");
					undef $debug;
				}
			}

			# Comando SHUTDOWN

			if ($datos[3] eq "shutdown")
			{
				if ($debug eq "ok") { botdebug("Comando 12SHUTDOWN ejecutado por 12$datos[0].") }
				print $nodo ":$nick SQUIT $nodoname\n";
			}

			# Comando RESTART

			if ($datos[3] eq "restart")
			{
				if ($debug eq "ok") { botdebug("Comando 12RESTART ejecutado por 12$datos[0].") }
				undef $nodo;
				sleep 2;
				goto principio;
			}

			# Comando ADDCHANNEL

			if ($datos[3] eq "addchannel")
			{
				if (!$datos[4]) { botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick ADDCHANNEL <#CANAL>\n"); }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else
				{
				open(CANALES, "+< canales.txt");
				while($linea = <CANALES>)
				{
					if (substr($linea, 0,1) ne "*")
					{
						$linea =~ s/
//;
						if ($datos[5] eq "$linea")
						{ 
							botpriv("$trio{$datos[0]} :4ERROR!! 12$datos[4] ya se encuentra en el autojoin.\n");
							goto fin;
						}
					}
				}
				print CANALES "$datos[4]\n";
				if ($debug eq "ok") { botdebug("12$datos[0] agrega 12$datos[4] como canal de autojoin.") }
				fin:
				close(CANALES);				
				}
			}

			# Comando DELCHANNEL

			if ($datos[3] eq "delchannel")
			{
				if (!$datos[4]) { botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick DELCHANNEL <#CANAL>\n"); }
				elsif (substr($datos[4], 0,1) ne "#") { botpriv("$trio{$datos[0]} :4ERROR!! El canal debe comenzar por 12#.") }			
				else
				{
				open(CANALES, "+< canales.txt");
				open(COPIA, ">copia.txt");
				while($linea = <CANALES>)
				{
					$linea =~ s/
//;
					if ($linea ne "$datos[4]") { print COPIA "$linea\n" }
				}
				if ($debug eq "ok") { botdebug("12$datos[0] elimina 12$datos[4] como canal de autojoin.") }
				close(CANALES);
				close(COPIA);
				rename ("canales.txt", "canales.old");
				rename ("copia.txt", "canales.txt");		
				}
			}

			# Comando ENTRYMSG

			if ($datos[3] eq "entrymsg")
			{
				if (!$datos[4]) { botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick ENTRYMSG <MENSAJE>\n"); }
				else
				{
					$welcome = "@datos[4..$#datos]";
					botpriv("$trio{$datos[0]} :Mensaje de entrada cambiado a: $welcome.");
					open(ENTRYMSG, ">>entrada.txt");
					print ENTRYMSG "$welcome\n";
					close(ENTRYMSG);
				}			
			}

			# Faltan... SPAM AKILL SCAN

		}

		# Comando ADMIN

		if (($datos[3] eq "admin") && ($datos[0] eq "$root"))
		{
			if (!$datos[4]) { botpriv("$trio{$datos[0]} :4ERROR!! Faltan parametros....  12/msg $nick ADMIN <ADD/DEL/LIST> <NICK>\n"); }
			if (($datos[4] eq "add") && ($datos[5]))
			{
				open(ADMINS, "+< admins.txt");
				while($linea = <ADMINS>)
				{
					$linea =~ s/
//;
					if ($datos[5] eq "$linea")
					{ 
						botpriv("$trio{$datos[0]} :4ERROR!! 12$datos[5] ya se encuentra como ADMIN\n");
						goto fin;
					}
				}
				print ADMINS "$datos[5]\n";
				if ($debug eq "ok") { botdebug("12$datos[0] agrega a 12$datos[5] como 12ADMINistrador.") }
				fin:
				close(ADMINS);
				admins();
			}
			if (($datos[4] eq "del") && ($datos[5]))
			{
				if ($debug eq "ok") { botdebug("12$datos[0] elimina a 12$datos[5] como 12ADMINistrador.") }
				open(ADMINS, "+< admins.txt");
				open(COPIA, ">copia.txt");
				while($linea = <ADMINS>)
				{
					$linea =~ s/
//;
					if ($linea ne "$datos[5]") { print COPIA "$linea\n" }
				}
				close(ADMINS);
				close(COPIA);
				rename ("admins.txt", "admins.old");
				rename ("copia.txt", "admins.txt");
				reset 'a';
				admins();
			}
			if ($datos[4] eq "list")
			{
				botpriv("$trio{$datos[0]} :Lista de 12ADMINistradores de 12$nick:\n");
				botpriv("$trio{$datos[0]} :\n");
				open(ADMINS, "admins.txt");
				while($linea = <ADMINS>)
				{
					$linea =~ s/
//;
					botpriv("$trio{$datos[0]} :12$linea\n");
				}
				close(ADMINS);
			}
		}
	}

	# RUTINILLAS

	# Para los comandos MASS

	if ($datos[1] eq "352")
	{
		$datos[7] =~ tr/A-Z/a-z/;
		if ($deop{$datos[3]} eq "ok") { print $nodo ":$nick M $datos[3] -o $trio{$datos[7]}\n" }
		if ($kick{$datos[3]} eq "ok") { print $nodo ":$nick KICK $datos[3] $trio{$datos[7]} :No puede permanecer en este canal.\n" }
		if ($op{$datos[3]} eq "ok") { print $nodo ":$nick M $datos[3] +o $trio{$datos[7]}\n" }
		if ($kill{$datos[3]} eq "ok") { print $nodo ":$nick KILL $trio{$datos[7]} :No puede permanecer en la red.\n" }
		if ($gline{$datos[3]} eq "ok") { print $nodo ":$nick GL * *${simboloarroba}$ip{$datos[7]} +300 :No puede permanecer en la red.\n" }
	}

}

sub conecta
{
	my $ctime = time();

	# Conectamos!

	print $nodo "PASS $nodopass\n";
	print $nodo "SERVER $nodoname 1 $ctime $ctime P10 ${numerico}P] :$nododesc\n";
	print $nodo "$numerico N $nick 1 $ctime $ident $host +diorXBkhgw DDNSca $nicknum :$nickdesc\n";
	print $nodo ":$nick J $canaldebug\n";
	print $nodo ":$nick M $canaldebug +xo $nicknum\n";
	print $nodo "$numerico WALLOP :Establecidos servicios auxiliares MAZINGUER para $network\n";
	print $nodo "$numerico SETTIME $ctime\n";

	canales();

	return;
}

# Genera el numérico identificativo del servidor
sub num
{
	my @num = qw(a A b B c C d D e E f F g G i I j J k K l L m M n N o O p P q Q r R s S t T u U v V w W x X y Y z Z);
	my $total = $#num; # da el nº de elementos del array @num
	my $random = int(rand($total));
	my $num = $num[$random];
	return($num);
}

#Para ahorrar código
sub botdebug
{
	print $nodo ":$nick P $canaldebug :@_\n";
}
sub botpriv
{
	print $nodo ":$nick P @_\n";
}

# Cargamos los ADMINS
sub admins
{
	open(ADMINS, "admins.txt");
	while($linea = <ADMINS>) {
			print "Cargando ADMIN... $linea\n";
			$linea =~ s/
//;
			$admin{$linea} = "ok";
	}
	close(ADMINS);
}

# Entrando en canales
sub canales
{
	open(CANALES, "canales.txt");
	while($linea = <CANALES>) {
		if (substr($linea, 0,1) eq "#")
		{
			print $nodo ":$nick J $linea\n";
			print "Entrando en canal $linea\n";
		}
	}
	close(CANALES);
}