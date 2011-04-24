module VarNameExpansion

	def varNameSplitter 
		/([\w]*)\.(.*)/
	end

	def expandCompoundVarName(varName, varDeposit)
	
		if varName =~ varNameSplitter
			key = $1
			rest = $2
			
			expression = varDeposit[key]
			
			if expression.is_a?(CompoundExpression)
				return expandCompoundVarName(rest, expression.evaluate)
			
			else
				puts varName
				p varDeposit
				p expression
				raise WTF
			end
		
		else
			return varDeposit[varName]
			
		end
	
	end
	
end