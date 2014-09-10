#!/usr/bin/env ruby
#

require 'pdf-reader'

lector = PDF::Reader.new("funcionarios_docentes_201406.pdf")

salida_texto = open("salida.txt","w")

tpage = lector.pages[0..1]

month = nil

tpage.each do |tp|
    txt = tp.text.lines
    new_page = true
    for i in txt
        if new_page then
            if txt.match(/Mes /) then
                new_page = false
            end
        else
            new_line = ("" != txt[0..9].to_s.trim) ? true : false
            if new_line  then
                unless month then
                    month = 
                end
            else
                # es parte de esos campos compuestos
            end
            
        end
    end
    
    
end

#lector.pages.each do |pagina|
#    puts "Writting page #{pagina.number}"
#    salida_texto.write(pagina.text)
#    salida_texto.write('\n')
#end

salida_texto.close
