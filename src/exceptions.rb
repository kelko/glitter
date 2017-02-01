class NotMyJobException < Exception
end

class WTF < Exception
end

class OnlyEvaluableExpressionsHere < Exception
    def init(variableName)
        @variableName = variableName
    end
end

class VariableNotInjected < Exception
    def init(variableName)
        @variableName = variableName
    end
end
