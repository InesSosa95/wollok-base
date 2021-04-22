Class {
	#name : #WollokVMClass,
	#superclass : #Object,
	#instVars : [
		'name',
		'ast'
	],
	#category : #'WollokVM-Interpreter'
}

{ #category : #accessing }
WollokVMClass >> allVariables [

	self flag: #todo.
	^ #()
]

{ #category : #'as yet unclassified' }
WollokVMClass >> answerToEverything [
	self shouldBeImplemented.
]

{ #category : #accessing }
WollokVMClass >> ast [
	^ ast
]

{ #category : #accessing }
WollokVMClass >> ast: anObject [
	ast := anObject
]

{ #category : #'as yet unclassified' }
WollokVMClass >> literalValue [
	^self
]

{ #category : #accessing }
WollokVMClass >> name [
	^ name
]

{ #category : #accessing }
WollokVMClass >> name: anObject [
	name := anObject
]

{ #category : #printing }
WollokVMClass >> printOn: aStream [

	super printOn: aStream.
	
	aStream
		space;
		nextPut: $(;
		print: name;
		nextPut: $)
		 
]
