Class {
	#name : #WollokBooleanLiteralNode,
	#superclass : #WollokAbstractNodeNode,
	#instVars : [
		'value'
	],
	#category : #'Wollok-Parser'
}

{ #category : #generated }
WollokBooleanLiteralNode >> acceptVisitor: anAbstractNodeVisitor [
	^ anAbstractNodeVisitor visitBooleanLiteral: self
]

{ #category : #generated }
WollokBooleanLiteralNode >> booleanValue [

	^ value value = 'true'
		ifTrue: [ true ]
		ifFalse: [ false ]
]

{ #category : #generated }
WollokBooleanLiteralNode >> tokenVariables [
	^ #(#value)
]

{ #category : #generated }
WollokBooleanLiteralNode >> value [
	^ value
]

{ #category : #generated }
WollokBooleanLiteralNode >> value: aSmaCCToken [
	value := aSmaCCToken
]
