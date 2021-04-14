Class {
	#name : #WollokASTInterpreter,
	#superclass : #Object,
	#instVars : [
		'bindings'
	],
	#category : #'WollokVM-Interpreter'
}

{ #category : #bindings }
WollokASTInterpreter >> addBinding: aName value: aWollokVMClass [ 
	
	bindings at: aName put: aWollokVMClass
]

{ #category : #bindings }
WollokASTInterpreter >> addBindingOfClass: aName fromString: aString [

	WollokReducedLoader new addBindingOfClass: aName fromString: aString in: self
]

{ #category : #interpreting }
WollokASTInterpreter >> initialize [

	super initialize.

	bindings := Dictionary new.
	
	WollokReducedLoader new loadInto: self
]

{ #category : #interpreting }
WollokASTInterpreter >> interpretProgram: aFileNode [ 

	| lastValue |

	aFileNode main elements do: [ :e | lastValue := e acceptVisitor: self ].

	^ lastValue	
]

{ #category : #comparing }
WollokASTInterpreter >> isFalse: aValue [

	^((aValue isKindOf: WollokVMLiteral) 
		ifTrue: [ aValue literalValue  ]
		ifFalse:[aValue]) not 
]

{ #category : #comparing }
WollokASTInterpreter >> isTrue: aValue [

	^(self isFalse: aValue) not
	
]

{ #category : #bindings }
WollokASTInterpreter >> resolve: aString [ 
	
	^ bindings at: aString
]

{ #category : #processing }
WollokASTInterpreter >> transform: anOperationString [

	anOperationString = '&&' ifTrue:[^#&].
	
	anOperationString = '||' ifTrue:[^#|].

	anOperationString = '===' ifTrue:[^#=].
	
	self notYetImplemented 
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitBinaryOperation: aWollokBinaryOperationNode [ 
		
	|leftValue rightValue operation| 	
		
	leftValue:= aWollokBinaryOperationNode leftOperand acceptVisitor: self.
	rightValue := aWollokBinaryOperationNode rightOperand acceptVisitor: self.
	operation :=self transform: (aWollokBinaryOperationNode operation value).
	
	^leftValue literalValue perform: operation with: rightValue literalValue. 
]

{ #category : #visiting }
WollokASTInterpreter >> visitBooleanLiteral: aWollokBooleanLiteralNode [ 

	^ self wollokBooleanFrom: aWollokBooleanLiteralNode booleanValue 
]

{ #category : #visiting }
WollokASTInterpreter >> visitNumberLiteral: aWollokNumberLiteralNode [ 

	^ self wollokNumberFrom: aWollokNumberLiteralNode numberValue
]

{ #category : #literals }
WollokASTInterpreter >> wollokBooleanFrom: aBoolean [ 

	^ WollokVMLiteral new
		wollokClass: (self resolve: 'wollok.lang.Boolean');
		literalValue: aBoolean ;
		yourself
]

{ #category : #literals }
WollokASTInterpreter >> wollokNumberFrom: anInteger [ 

	^ WollokVMLiteral new
		wollokClass: (self resolve: 'wollok.lang.Number');
		literalValue: anInteger;
		yourself
]
