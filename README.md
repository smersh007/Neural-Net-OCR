 "Character Recognition using Neural Networks."

Abstract:

The Ultimate Goal of this paper is to produce a `Text-to-ASCII' translator implemented in software. The software is to scan printed text and produce ASCII output using Neural Network techniques. At the time this paper was commenced, no neural network packages were available, so the time-consuming task of producing one was undertaken. The result was the emergence of some general tools for understanding and testing neuro-modelling concepts. The tools provide a testbed where the Text-to-ASCII translation can be seen to function. In combination with the tools, this paper also serves as a training ground for future research. I have supplied some novel ideas for applications that I believe will inspire further studies in the exciting field of neuro-computing. Wherever possible, analogies are drawn to electrical engineering in an attempt to improve comprehensibility by evoking concepts familiar to electrical engineers.



Thesis was completed in 1989 formy Degree in Electrical Engineering at The University of NSW, Sydney Australia.
Software was developed with Turbo Pascal V4.0 running on DOS on 4.77Mhz 8086.
There is a GUI developed as part of the work.

There is an interesting section in theis thesis

6.3. An Intelligent Conversation Machine.

One criterion by which we can say a machine is intelligent is if by conducting a conversation with it, we cannot decide whether it is a machine or a human. If a simple, multi-layered neural model is assumed, I believe a machine that can produce a `sensible' response to a query or statement is realizable. The learning and testing phases could run simultaneously by interaction with a human. The net could be made to respond to human input and the human would respond to the net in a tightly closed loop. The strategy could take the following form:

1: The net is trained on some initial source   response pairs.
2: The human would enter a statement or query.
3: The net would respond.
4: The human would respond.
5: The net response   human response form a new input   output pair to be learned by the net.
6: The process continues to 3:

ASCII valued text could be presented directly to the net but would result in a very brittle system, so some form of sentence decomposition would be required to reduce the burden on the network.

