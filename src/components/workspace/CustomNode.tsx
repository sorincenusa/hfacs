import React, { memo } from 'react';
import { Handle, Position, NodeProps } from 'reactflow';
import { HFACS_TAXONOMY } from '@/lib/hfacs-taxonomy';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue, SelectGroup, SelectLabel } from '@/components/ui/select';
import { Paperclip } from 'lucide-react';

export const CustomNode = memo(({ data, isConnectable }: NodeProps) => {
  const { label, description, level_id, category, onChange } = data;

  const currentLevel = HFACS_TAXONOMY.find((t) => t.level_id === level_id);

  // Default styling if no category is selected
  const headerColor = currentLevel ? currentLevel.color_main : 'bg-slate-300';
  const bgColor = currentLevel ? currentLevel.color_pale : 'bg-white';

  const handleCategoryChange = (value: string) => {
    // Find the level this category belongs to
    for (const level of HFACS_TAXONOMY) {
      if (level.categories.includes(value)) {
        onChange({ category: value, level_id: level.level_id });
        return;
      }
    }
  };

  return (
    <div className={`w-80 shadow-lg rounded-md border-2 border-slate-200 overflow-hidden ${bgColor}`}>
      <Handle
        type="target"
        position={Position.Top}
        isConnectable={isConnectable}
        className="w-3 h-3 bg-slate-500"
      />

      {/* Header */}
      <div className={`px-4 py-2 flex justify-between items-center ${headerColor}`}>
        <div className="font-bold text-white text-sm w-full">
            {currentLevel ? currentLevel.level_name : 'Unclassified Node'}
        </div>
      </div>

      <div className="p-4 flex flex-col gap-3">
        <div className="flex flex-col gap-1">
          <Label className="text-xs text-slate-500 font-semibold">Title</Label>
          <Input
            value={label}
            onChange={(e) => onChange({ label: e.target.value })}
            className="h-8 text-sm bg-white/50"
            placeholder="Node title"
          />
        </div>

        <div className="flex flex-col gap-1">
          <Label className="text-xs text-slate-500 font-semibold">HFACS Category</Label>
          <Select value={category} onValueChange={handleCategoryChange}>
            <SelectTrigger className="h-8 text-sm bg-white/50">
              <SelectValue placeholder="Select classification" />
            </SelectTrigger>
            <SelectContent>
              {HFACS_TAXONOMY.map((level) => (
                <SelectGroup key={level.level_id}>
                  <SelectLabel>{level.level_name}</SelectLabel>
                  {level.categories.map((cat) => (
                    <SelectItem key={cat} value={cat}>
                      {cat}
                    </SelectItem>
                  ))}
                </SelectGroup>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="flex flex-col gap-1">
          <Label className="text-xs text-slate-500 font-semibold">Description</Label>
          <Textarea
            value={description}
            onChange={(e) => onChange({ description: e.target.value })}
            className="text-sm min-h-[60px] bg-white/50 resize-none"
            placeholder="Detailed description..."
          />
        </div>

        <div className="flex justify-start items-center text-slate-400 text-xs mt-1 hover:text-slate-600 cursor-pointer">
            <Paperclip className="w-3 h-3 mr-1" /> Add Attachment
        </div>
      </div>

      <Handle
        type="source"
        position={Position.Bottom}
        isConnectable={isConnectable}
        className="w-3 h-3 bg-slate-500"
      />
    </div>
  );
});

CustomNode.displayName = 'CustomNode';
