class NotMyJobException < Exception
end

class OnlySimpleExpressionsHere < Exception
end

class WTF < Exception
end

class VariableNotInjected < Exception
    def init(variableName)
        @variableName = variableName
    end
end
