Extension { #name : #Number }

{ #category : #'*WollokVM-Interpreter' }
Number >> truncate: anInteger [

	^ self
		roundDownTo:
			([ :number | 
			| result |
			result := ''.
			number timesRepeat: [ result := result , '0' ].
			result := result , '1'.
			result size > 1
				ifTrue: [ result := result first asString , '.' , (result withoutPrefix: '0') ].
			NumberParser parse: result ] value: anInteger)
]
