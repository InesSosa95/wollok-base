Class {
	#name : #WollokQualifiedNameNode,
	#superclass : #WollokAbstractNodeNode,
	#instVars : [
		'identifiers',
		'periodTokens'
	],
	#category : #'Wollok-Parser'
}

{ #category : #generated }
WollokQualifiedNameNode >> acceptVisitor: anAbstractNodeVisitor [
	^ anAbstractNodeVisitor visitQualifiedName: self
]

{ #category : #converting }
WollokQualifiedNameNode >> asWollokQualifiedName [
	
	^ 'wollok.lang.' , ((self identifiers collect: [ :e | e value ]) joinUsing: '.')
]

{ #category : #converting }
WollokQualifiedNameNode >> className [ 
	
	^ ((self identifiers collect: [ :e | e value ]) joinUsing: '.')
]

{ #category : #generated }
WollokQualifiedNameNode >> compositeTokenVariables [
	^ #(#identifiers #periodTokens)
]

{ #category : #generated }
WollokQualifiedNameNode >> identifiers [
	^ identifiers
]

{ #category : #generated }
WollokQualifiedNameNode >> identifiers: anOrderedCollection [
	identifiers := anOrderedCollection
]

{ #category : #'generated-initialize-release' }
WollokQualifiedNameNode >> initialize [
	super initialize.
	identifiers := OrderedCollection new: 2.
	periodTokens := OrderedCollection new: 2.
]

{ #category : #generated }
WollokQualifiedNameNode >> periodTokens [
	^ periodTokens
]

{ #category : #generated }
WollokQualifiedNameNode >> periodTokens: anOrderedCollection [
	periodTokens := anOrderedCollection
]

{ #category : #converting }
WollokQualifiedNameNode >> wollokClassName [ 
	
	^((self identifiers collect: [ :e | e value ]) joinUsing: '.') 
]
