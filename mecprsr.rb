#!/usr/bin/env ruby
#

require 'pdf-reader'

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
    
    puts "Iterando '#{cadena.size}' caracteres"
    (inicio..cadena.size-1).each do |indice|
        if cadena[indice] == "\s" then
            if palabra_entera then
                palabra_entera = false
                palabra << cadena[indice]
            else
                espacios = true
            end
        else
            # Si es cualquier otro caracter que no es espacio
            if espacios || cadena[indice] == "\n"then
                # Ver si esto es realmente necesario
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
    return retornar
end

def get_range(arreglo_hash, index)

    hash_temp = arreglo_hash[index]
    
    array_temp = hash_temp.values
    
    return (array_temp[0][0]..array_temp[0][1])
end


#lector = PDF::Reader.new("funcionarios_docentes_201406.pdf")

salida_texto = open("salida.txt","r")

#tpage = lector.pages[0..1] 
# Improving test performance



## TESTING

#p = lector.page(1)

#linea = "Mes        Año      N° Documento    Nombre completo                                  Objeto de Gasto                  Estado       Antiguedad             Concepto                             Dependencia                       Cargo                     N° Matricula    Rubro        Monto Rubro  Cantidad         Asignación\n"
#xc = determinar_cabecera(linea)
#xc.each do |k|
#    puts "#{k}"
#end


#p.text.lines.each do |linea|
#    puts "'#{linea}'"
#    xc = determinar_cabecera(linea)
#    xc.each do |k,v|
#        puts "#{k} -> #{v}"
#    end
#end

## TESTING



#tpage = [lector.page(1), lector.page(2)]
txt = salida_texto.lines

month = nil

puts("Iterando sobre las páginas")

linea_actual = []
#tpage.each do |tp|
#    txt = tp.text.lines
    new_page = true
    escribiendo_linea = false
    for linea in txt
        if new_page then
            if linea[/^Mes /] then
                # Se define la cabecera
                new_page = false
                cabecera = determinar_cabecera(linea)
                puts "La cabecera tiene #{cabecera.count} campos"
            end
        else
            next if linea.strip.empty? 
            range = get_range(cabecera, 0) # Mes
            new_line = !(linea[range].strip.empty?)
            if new_line then
                if escribiendo_linea then
                    escribiendo_linea = false
                    puts linea_actual # HERE!
                else
                    escribiendo_linea = true
                    linea_actual = []
                    (0..cabecera.count-1).each do |i|
                        linea_actual << linea[get_range(cabecera,i)].strip
                    end
                end
            else
                # es parte de esos campos compuestos
                (0..cabecera.count-1).each do |i|
                    t = linea[get_range(cabecera,i)]
                    unless t.nil? then
                        linea_actual[i] << t.strip
                    end
                end
            end
        end
    end
    
#end

#lector.pages.each do |pagina|
#    puts "Writting page #{pagina.number}"
#    salida_texto.write(pagina.text)
#    salida_texto.write('\n')
#end

salida_texto.close
