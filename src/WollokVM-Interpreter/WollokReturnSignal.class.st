Class {
	#name : #WollokReturnSignal,
	#superclass : #Exception,
	#instVars : [
		'returnValue'
	],
	#category : #'WollokVM-Interpreter'
}

{ #category : #accessing }
WollokReturnSignal >> returnValue [

	^returnValue 
]

{ #category : #accessing }
WollokReturnSignal >> returnValue: aValue [

	returnValue := aValue
]
