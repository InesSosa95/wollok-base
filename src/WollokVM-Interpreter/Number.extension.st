Extension { #name : #Number }

{ #category : #'*WollokVM-Interpreter' }
Number >> truncate: anInteger [
	| result |
	
	result := ''.
	anInteger timesRepeat: [ result := result , '0' ].
	result := result , '1'.
	result size > 1
		ifTrue: [ result := result first asString , '.' , (result withoutPrefix: '0') ].
			
	^ self roundDownTo: (NumberParser parse: result ) 
]
