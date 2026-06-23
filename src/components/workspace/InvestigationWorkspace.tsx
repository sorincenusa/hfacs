"use client";

import React, { useState, useCallback, useMemo } from 'react';
import ReactFlow, {
  Background,
  Controls,
  MiniMap,
  applyNodeChanges,
  applyEdgeChanges,
  addEdge,
  Node,
  Edge,
  NodeChange,
  EdgeChange,
  Connection,
  ReactFlowProvider
} from 'reactflow';
import 'reactflow/dist/style.css';
import { CustomNode } from './CustomNode';
import { Button } from '@/components/ui/button';
import { v4 as uuidv4 } from 'uuid';

const initialNodes: Node[] = [
  {
    id: 'node-1',
    type: 'hfacsNode',
    position: { x: 250, y: 100 },
    data: {
      label: 'Initial Event',
      description: '',
      level_id: null,
      category: '',
      onChange: () => {},
    },
  },
];

const initialEdges: Edge[] = [];

export function InvestigationWorkspace() {
  const [nodes, setNodes] = useState<Node[]>(initialNodes);
  const [edges, setEdges] = useState<Edge[]>(initialEdges);

  const onNodesChange = useCallback(
    (changes: NodeChange[]) => setNodes((nds) => applyNodeChanges(changes, nds)),
    []
  );

  const onEdgesChange = useCallback(
    (changes: EdgeChange[]) => setEdges((eds) => applyEdgeChanges(changes, eds)),
    []
  );

  const onConnect = useCallback(
    (params: Connection) => setEdges((eds) => addEdge(params, eds)),
    []
  );

  const handleNodeDataChange = useCallback((nodeId: string, newData: any) => {
    setNodes((nds) =>
      nds.map((node) => {
        if (node.id === nodeId) {
          return {
            ...node,
            data: {
              ...node.data,
              ...newData,
            },
          };
        }
        return node;
      })
    );
  }, []);

  const addNode = useCallback(() => {
    const newNode: Node = {
      id: `node-${uuidv4()}`,
      type: 'hfacsNode',
      position: { x: Math.random() * 400 + 100, y: Math.random() * 400 + 100 },
      data: {
        label: 'New Node',
        description: '',
        level_id: null,
        category: '',
      },
    };
    setNodes((nds) => [...nds, newNode]);
  }, []);

  // Pass down the change handler to the nodes
  const nodeTypes = useMemo(() => ({ hfacsNode: CustomNode }), []);

  const nodesWithHandlers = useMemo(() => {
     return nodes.map(node => ({
         ...node,
         data: {
             ...node.data,
             onChange: (newData: any) => handleNodeDataChange(node.id, newData)
         }
     }))
  }, [nodes, handleNodeDataChange]);

  return (
    <div className="flex flex-col h-screen w-full bg-slate-50">
      <div className="p-4 bg-white border-b flex justify-between items-center shadow-sm">
        <div>
          <h1 className="text-xl font-bold">Investigation Workspace</h1>
          <p className="text-sm text-slate-500">Causal Mapping & HFACS Classification</p>
        </div>
        <Button onClick={addNode}>Add Node</Button>
      </div>

      <div className="flex-1 w-full h-full">
        <ReactFlowProvider>
          <ReactFlow
            nodes={nodesWithHandlers}
            edges={edges}
            onNodesChange={onNodesChange}
            onEdgesChange={onEdgesChange}
            onConnect={onConnect}
            nodeTypes={nodeTypes}
            fitView
          >
            <Background color="#ccc" gap={16} />
            <Controls />
            <MiniMap />
          </ReactFlow>
        </ReactFlowProvider>
      </div>
    </div>
  );
}
