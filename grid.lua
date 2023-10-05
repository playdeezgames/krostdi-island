local grid={}
grid.Create=function(columns,rows,generator)
    local output={}
    for column=1,columns do
        output[column]={}
        for row=1,rows do
            output[column][row]=generator()
        end
    end
    return output
end
return grid