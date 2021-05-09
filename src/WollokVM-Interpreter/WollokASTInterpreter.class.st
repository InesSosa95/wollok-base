Class {
	#name : #WollokASTInterpreter,
	#superclass : #Object,
	#instVars : [
		'bindings',
		'variableAssociation'
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

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> perform: aSelector on: aReceiver [


	^(aReceiver isKindOf: WollokVMClass)
		ifTrue: [ | methods |
			methods := aReceiver ast acceptVisitor: self.
			(methods select: [ :method | method name value = aSelector ]) first acceptVisitor: self ]
		ifFalse: [ aReceiver perform: aSelector ]
]

{ #category : #bindings }
WollokASTInterpreter >> resolve: aString [ 
	
	^ bindings at: aString
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
WollokASTInterpreter >> variableAssociation [
	
	
	^variableAssociation ifNil: [  variableAssociation :=  Dictionary new ] ifNotNil:  [ :association | association  ]
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

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitBlockExpression: aWollokBlockExpressionNode [

	^aWollokBlockExpressionNode expressions inject: nil into:[:result :expression | expression acceptVisitor: self]. 
]

{ #category : #visiting }
WollokASTInterpreter >> visitBooleanLiteral: aWollokBooleanLiteralNode [ 

	^ self wollokBooleanFrom: aWollokBooleanLiteralNode booleanValue 
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitClosure: aWollokClosureNode [
	
	aWollokClosureNode expression expressions
		do: [ :expression | expression acceptVisitor: self ]
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitConstructorCall: aWollokConstructorCallNode [

	|className|
	
	className:= (aWollokConstructorCallNode classRef acceptVisitor: self).
	
	^bindings
		at: className ifAbsent:[bindings at: 'wollok.lang.', className  ]
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitFile: aWollokFileNode [ 
	
	^aWollokFileNode elements first methods
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitIfExpression: aWollokIfExpressionNode [ 
	|conditionResult result|
	
	conditionResult := (aWollokIfExpressionNode condition acceptVisitor: self) literalValue.
	
	^conditionResult 
		ifTrue: [ aWollokIfExpressionNode then acceptVisitor: self ]
		ifFalse: [ aWollokIfExpressionNode else acceptVisitor: self ]
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitMemberFeatureCall: aWollokMemberFeatureCallNode [

	| receiver message arguments result |
	receiver := (aWollokMemberFeatureCallNode receiver
		acceptVisitor: self) literalValue.
	message := self
		translateFeatureCallFrom: aWollokMemberFeatureCallNode.
	arguments := aWollokMemberFeatureCallNode arguments
		collect: [ :arg | (arg acceptVisitor: self) literalValue ].
		
	arguments size = 0 ifTrue: [ result := self perform: message on: receiver ].
	arguments size = 1	ifTrue: [ result := self perform: message on: receiver with: arguments first ].
	arguments size > 1	ifTrue: [ result := self	perform: message on: receiver withArguments: arguments ].
			
	^ self wollokVMLiteralFrom: result
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitMethodDeclaration: aWollokMethodDeclarationNode [ 

	^aWollokMethodDeclarationNode expression acceptVisitor: self
	
]

{ #category : #visiting }
WollokASTInterpreter >> visitNumberLiteral: aWollokNumberLiteralNode [ 

	^ self wollokNumberFrom: aWollokNumberLiteralNode numberValue
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitQualifiedName: aWollokQualifiedNameNode [

	^ aWollokQualifiedNameNode wollokClassName
]

{ #category : #visiting }
WollokASTInterpreter >> visitStringLiteral: aWollokStringLiteralNode [ 

	^ self wollokStringFrom: aWollokStringLiteralNode value value 
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitThrow: aWollokThrowNode [ 

	^aWollokThrowNode exception acceptVisitor: self
	
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitTry: aWollokTryNode [

	[ ^ [ aWollokTryNode expression acceptVisitor: self ]
		on: Error
		do: [ :signal | 
			aWollokTryNode catchBlocks
				detect: [ :catch | catch exceptionType className = signal className ]
				ifFound: [ :catch | catch acceptVisitor: self ]
				ifNone: [ signal pass ] ] ]
		ensure: [ aWollokTryNode alwaysExpression acceptVisitor: self ]
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitUnaryOperation: aWollokUnaryOperationNode [ 
	
	|rightValue operationSymbol result|
	
	rightValue := (aWollokUnaryOperationNode rightOperand acceptVisitor: self) literalValue.
	operationSymbol := self translateUnaryOperationFrom: aWollokUnaryOperationNode.
	
	result := rightValue perform: operationSymbol. 
	
	^self wollokVMLiteralFrom: result
]

{ #category : #'as yet unclassified' }
WollokASTInterpreter >> visitVariableDeclaration: aWollokVariableDeclarationNode [ 

	self variableAssociation at: (aWollokVariableDeclarationNode variable name) put: (aWollokVariableDeclarationNode right acceptVisitor: self)
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
	(aValue isKindOf: Exception)
		ifTrue: [ ^ aValue signal ]
		
	"Si llega hasta aqui el tipo no esta soportado aun."
	self shouldBeImplemented 
]
