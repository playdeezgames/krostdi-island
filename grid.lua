return {
    Create=function(columns,rows,generator)
        local output={}
        for column=1,columns do
            output[column]={}
            for row=1,rows do
                output[column][row]=generator(column,row)
            end
        end
        return output
    end
}