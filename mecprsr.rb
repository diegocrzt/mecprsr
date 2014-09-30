#!/usr/bin/env ruby
#

# Parser específico para la salida de pdftotext, del documento
# del MEC (Nómina de Funcionarios Docentes)
# Ver wrapper mecprsr.sh

class CadenaInvalida < RuntimeError
end

def determinar_cabecera(cadena = nil)
  unless cadena then
    raise(CadenaInvalida, "El parámetro cadena no puede ser #{cadena}")
  end

  palabra_entera = true
  espacios = false
  palabra = ""
  retornar = []
  inicio = 0
  fin = inicio

  # FIXME
  # Necesitamos hacer esto para corregir la salida de pdftotext
  j = 0
  k = 0
  while cadena[j] == "\s" do
    j = j + 1
  end

  while cadena[j] != "\s" do
    t = cadena[k]
    cadena[k] = cadena[j]
    cadena[j] = t
    j = j + 1
    k = k + 1
  end

  # I know this is ugly, but ...

  cadena.gsub!(' Año', 'Año ')

  #FIXME

  (inicio..cadena.size-1).each do |indice|
    if cadena[indice] == "\s"
      # Manejar los espacios
      if palabra_entera
        palabra_entera = false
        palabra << cadena[indice]
      else
        espacios = true
      end
    else
      # Si es cualquier otro caracter que no es espacio
      if espacios || cadena[indice] == "\n"
        # Se llegó al final de un campo de texto
        espacios = false
        temp_arreglo = [inicio, indice-1]
        temp_hash = {palabra.strip =>
                         temp_arreglo}
        retornar << temp_hash
        inicio = indice
        palabra = ""
      end
      palabra_entera = true
      palabra << cadena[indice]
    end
  end
  retornar
end

# Función auxiliar, obtiene el rango de un campo
def get_range(arreglo_hash, index)

  hash_temp = arreglo_hash[index]

  array_temp = hash_temp.values

  return (array_temp[0][0]..array_temp[0][1])
end

# BEGIN
def main(fichero_entrada, fichero_salida)
  begin
    entrada_texto = open(fichero_entrada, "r")
  rescue => e
    puts e.message
    puts "No se pudo abrir el fichero #{fichero_entrada} verifique que exista"
    return 'FALLO AL INTENTAR ABRIR EL FICHERO'
  end

  salida_texto = open(fichero_salida, "w")

  txt = entrada_texto.each_line

  linea_actual = []
  new_page = true
  escribiendo_linea = false
  for linea in txt
    if linea[/^\s*MINISTERIO\s*DE\s*EDUCACION\s*/] then
      new_page = true
      next
    end
    if new_page then
      if linea[/^\s*Mes /] then
        # Se define la cabecera
        new_page = false
        cabecera = determinar_cabecera(linea)
      end
    else
      next if linea.strip.empty?
      range = get_range(cabecera, 0) # Mes
      new_line = !(linea[range].strip.empty?)
      if new_line then
        if escribiendo_linea then
          escribiendo_linea = false
          #puts linea_actual
          limit = linea_actual.size
          (0..limit-1).each do |k|
            salida_texto.write(linea_actual[k])
            salida_texto.write(k == limit-1 ? "\n" : ";")
            #print '.'
          end
        else
          escribiendo_linea = true
          linea_actual = []
          (0..cabecera.count-1).each do |i|
            if i == cabecera.count - 1 then
              last_range = get_range(cabecera, i)
              last_range = (last_range.min..linea.size-1)
              linea_actual << linea[last_range].strip
            else
              linea_actual << linea[get_range(cabecera, i)].strip
            end
          end
        end
      else
        # es parte de esos campos compuestos
        (0..cabecera.count-1).each do |i|
          t = linea[get_range(cabecera, i)]
          unless t.nil? or t.strip.empty? then
            linea_actual[i] << (" " << t.strip)
          end
        end
      end
    end
  end

  entrada_texto.close
  salida_texto.close

  return 'EXITO'
end


if $0 == __FILE__ #RUBY MAGIC!
  script_name = $0
  entrada = ARGV[0]
  salida = ARGV[1]
  if entrada.nil?
    puts "uso : #{script_name} funcionarios_docentes_YYYYmm.txt [funcionarios_docentes_YYYYmm.csv]"
    exit -1 # No se pasó el fichero de entrada como parámetro
  end

  if salida.nil?
    temp = entrada.split('.')
    k = temp.size()-1
    salida = ""
    if (k == 1 or k == 0) then
      salida = temp[0]
    else
      (0..k-1).each do |i|
        salida << (temp[i] << ((i == k-1) ? "" : "."))
      end
    end
    salida << '.csv'
  end

  ret_val = main(entrada,salida)

  puts "El resultado fue #{ret_val}"
end