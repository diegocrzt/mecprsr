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

def get_range(hash, index)

    hash_temp = hash(index)
    
    array_temp = hash_temp.values
    
    range =  Range(array_temp[0][0]..array_temp[0][1])
    
    return range
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

#tpage.each do |tp|
#    txt = tp.text.lines
    new_page = true
    for linea in txt
        if new_page then
            if linea[/^Mes /] then
                # Se define la cabecera
                new_page = false
                puts "#{txt.size} -> '#{linea}'"
                cabecera = determinar_cabecera(linea)
                puts "La cabecera tiene #{cabecera.count} campos"
            end
        else
            range = get_range(cabecera, 0) # Mes
            new_line = ("" != linea[range].strip) ? true : false
            if new_line then
                
            else
                # es parte de esos campos compuestos
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
