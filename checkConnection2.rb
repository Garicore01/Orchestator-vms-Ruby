#!/usr/bin/ruby
require 'net/ssh'

# PRE: Verdad
# POST: Devuelve las maquinas que hay en el archivo <hosts_file>
def read_hosts(hosts_file)
  File.read(hosts_file).split("\n").map(&:strip)
end


# Ejecuta un comando ping en todas las máquinas y muestra el resultado
# PRE: Verdad
# POST: Ejecuta un nc para comprobar si la maquina remota esta escuchando
#       en el puerto 22
def ping_command(hosts)
  hosts.each do |host|
    result = `nc -z -6 -w 1 #{host} 22 2>&1`
    status = $?.success? ? 'FUNCIONA' : 'FALLO'
    puts "#{host}: #{status}"
  end
end


# PRE: <command> debe ser un comando válido en la maquina remota
# POST: Se ejecuta <command> en las maquinas configuradas en el fichero.
def remote_command(hosts, command)
  hosts.each do |host|
    clave = { keys: ["/home/a848905/.ssh/id_rsa"] }
    Net::SSH.start(host, ENV['USER'], clave) do |ssh|
      puts "#{host}:"
      output = ssh.exec!(command)
      puts "  #{output}"
    end
  end
end



#################################################################################################
#################################################################################################
#                                       PRINCIPAL
#################################################################################################
#################################################################################################

# Caso en el que se pide la ayuda del programa
if ARGV[0] == "help"
  puts "Manual de uso de la herramienta:\n"
  puts "Para comprobar si las maquinas estan escuchando en el puerto 22, utilice la opción p.\n"
  puts "Ejemplo de uso:\n"
  puts "ruby checkConnection p\n"
  puts "Para ejecutar un comando en las maquinas remotas mediante ssh, utilice la opción s y escriba los comandos\n"
  puts 'Ejemplo de uso:\n'
  puts 'ruby checkConnection s "echo "Hola""'
end

if ARGV.length < 1
  puts 'Uso: ruby chechConnection <subcomando> <opciones comandos>'
  exit(1)
end

hosts_file = File.expand_path('~/.u/hosts')
subcomando = ARGV.shift #Obtengo el primer comando
opciones = ARGV.join(' ') #Obtengo el resto de opciones 

case subcomando
when 'p'
  ping_command(read_hosts(hosts_file))
when 's'
  remote_command(read_hosts(hosts_file), opciones)
else
  puts "Subcomando no reconocido: #{subcomando}"
end
 
