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

	anOperationString = '==' ifTrue:[^#=].	

	anOperationString = '===' ifTrue:[^#==].
	
	^anOperationString asSymbol  
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> translateBinaryOperationFrom: aWollokBinaryOperationNode for: aLiteralValue [ 

	|operationString|
	
	operationString := aWollokBinaryOperationNode operation value.

	(aLiteralValue isKindOf: Boolean) ifTrue: [
		operationString = '&&' ifTrue:[^#&].	
		operationString = '||' ifTrue:[^#|].].

	(aLiteralValue isKindOf: String) ifTrue: [
		operationString = '+' ifTrue:[^#,].	
		].
	
	operationString = '==' ifTrue:[^#=].
	operationString = '===' ifTrue:[^#==].
	
	^operationString asSymbol  
]

{ #category : #processing }
WollokASTInterpreter >> translateFeatureCallFrom: aWollokBinaryOperationNode [ 

	|featureString|
	
	featureString := aWollokBinaryOperationNode feature value.
	
	aWollokBinaryOperationNode arguments size = 0 ifTrue: [ ^featureString asSymbol ].
	aWollokBinaryOperationNode arguments size = 1 ifTrue: [ ^(featureString , ':') asSymbol ]
	
]

{ #category : #processing }
WollokASTInterpreter >> translateUnaryOperationFrom: aWollokBinaryOperationNode [ 

	|operationString|
	
	operationString := aWollokBinaryOperationNode operation value.

	operationString = '-' ifTrue:[^#negated].
	
	^operationString asSymbol  
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitBinaryOperation: aWollokBinaryOperationNode [ 
		
	|leftValue rightValue operationSymbol result| 	
		
	leftValue := (aWollokBinaryOperationNode leftOperand acceptVisitor: self) literalValue.
	rightValue := (aWollokBinaryOperationNode rightOperand acceptVisitor: self) literalValue.
	operationSymbol := self translateBinaryOperationFrom: aWollokBinaryOperationNode for: leftValue.
	
	result := leftValue perform: operationSymbol with: rightValue. 
	
	^self wollokVMLiteralFrom: result
]

{ #category : #visiting }
WollokASTInterpreter >> visitBooleanLiteral: aWollokBooleanLiteralNode [ 

	^ self wollokBooleanFrom: aWollokBooleanLiteralNode booleanValue 
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitMemberFeatureCall: aWollokMemberFeatureCallNode [ 
	|receiver message arguments result|
	
	receiver := (aWollokMemberFeatureCallNode receiver acceptVisitor: self) literalValue.
	message := self translateFeatureCallFrom: aWollokMemberFeatureCallNode.
	arguments := aWollokMemberFeatureCallNode arguments collect: [ :arg| (arg acceptVisitor: self) literalValue].
	
	arguments size = 0 ifTrue: [result := receiver perform: message ].
	arguments size = 1 ifTrue: [result := receiver perform: message with: arguments first].
	arguments size > 1 ifTrue: [result := receiver perform: message withArguments: arguments].
	
	^self wollokVMLiteralFrom: result
]

{ #category : #visiting }
WollokASTInterpreter >> visitNumberLiteral: aWollokNumberLiteralNode [ 

	^ self wollokNumberFrom: aWollokNumberLiteralNode numberValue
]

{ #category : #visiting }
WollokASTInterpreter >> visitStringLiteral: aWollokStringLiteralNode [ 

	^ self wollokStringFrom: aWollokStringLiteralNode value value 
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitUnaryOperation: aWollokUnaryOperationNode [ 
	
	|rightValue operationSymbol result|
	
	rightValue := (aWollokUnaryOperationNode rightOperand acceptVisitor: self) literalValue.
	operationSymbol := self translateUnaryOperationFrom: aWollokUnaryOperationNode.
	
	result := rightValue perform: operationSymbol. 
	
	^self wollokVMLiteralFrom: result
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

{ #category : #literals }
WollokASTInterpreter >> wollokStringFrom: aString [

	^ WollokVMLiteral new
		wollokClass: (self resolve: 'wollok.lang.String');
		literalValue: aString withoutQuoting ;
		yourself
]

{ #category : #transforming }
WollokASTInterpreter >> wollokVMLiteralFrom: aValue [
	(aValue isKindOf: Boolean)
		ifTrue: [ ^ self wollokBooleanFrom: aValue ].
	(aValue isKindOf: Number)
		ifTrue: [ ^ self wollokNumberFrom: aValue ].
	(aValue isKindOf: String)
		ifTrue: [ ^ self wollokStringFrom: aValue ].
		
	"Si llega hasta aqui el tipo no esta soportado aun."
	self shouldBeImplemented 
]
