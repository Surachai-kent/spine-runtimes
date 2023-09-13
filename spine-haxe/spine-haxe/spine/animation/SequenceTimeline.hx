package spine.animation;

import openfl.Vector;
import spine.attachments.VertexAttachment;
import spine.attachments.Attachment;

class SequenceTimeline extends Timeline implements SlotTimeline {
	static var ENTRIES = 3;
	static var MODE = 1;
	static var DELAY = 2;

	var slotIndex:Int;
	var attachment:HasTextureRegion;

	public function new(frameCount:Int, slotIndex:Int, attachment:HasTextureRegion) {
		super(frameCount, Vector.ofArray([
			Std.string(Property.sequence) + "|" + Std.string(slotIndex) + "|" + Std.string(attachment.sequence.id)
		]));
		this.slotIndex = slotIndex;
		this.attachment = attachment;
	}

	public override function getFrameEntries():Int {
		return SequenceTimeline.ENTRIES;
	}

	public function getSlotIndex():Int {
		return this.slotIndex;
	}

	public function getAttachment():Attachment {
		return cast(attachment, Attachment);
	}

	/** Sets the time, mode, index, and frame time for the specified frame.
	 * @param frame Between 0 and <code>frameCount</code>, inclusive.
	 * @param time Seconds between frames. */
	public function setFrame(frame:Int, time:Float, mode:SequenceMode, index:Int, delay:Float) {
		frame *= SequenceTimeline.ENTRIES;
		frames[frame] = time;
		frames[frame + SequenceTimeline.MODE] = mode.value | (index << 4);
		frames[frame + SequenceTimeline.DELAY] = delay;
	}

	public override function apply(skeleton:Skeleton, lastTime:Float, time:Float, events:Vector<Event>, alpha:Float, blend:MixBlend,
			direction:MixDirection):Void {
		var slot = skeleton.slots[this.slotIndex];
		if (!slot.bone.active)
			return;
		var slotAttachment = slot.attachment;
		var attachment = cast(this.attachment, Attachment);
		if (slotAttachment != attachment) {
			if (!Std.isOfType(slotAttachment, VertexAttachment) || cast(slotAttachment, VertexAttachment).timelineAttachment != attachment)
				return;
		}

		if (time < frames[0]) { // Time is before first frame.
			if (blend == MixBlend.setup || blend == MixBlend.first)
				slot.sequenceIndex = -1;
			return;
		}

		var i = Timeline.search(frames, time, SequenceTimeline.ENTRIES);
		var before = frames[i];
		var modeAndIndex = Std.int(frames[i + SequenceTimeline.MODE]);
		var delay = frames[i + SequenceTimeline.DELAY];

		if (this.attachment.sequence == null)
			return;
		var index = modeAndIndex >> 4,
			count = this.attachment.sequence.regions.length;
		var mode = SequenceMode.values[modeAndIndex & 0xf];
		if (mode != SequenceMode.hold) {
			index += Std.int(((time - before) / delay + 0.00001));
			switch (mode) {
				case SequenceMode.once:
					index = Std.int(Math.min(count - 1, index));
				case SequenceMode.loop:
					index %= count;
				case SequenceMode.pingpong:
					var n = (count << 1) - 2;
					index = n == 0 ? 0 : index % n;
					if (index >= count)
						index = n - index;
				case SequenceMode.onceReverse:
					index = Std.int(Math.max(count - 1 - index, 0));
				case SequenceMode.loopReverse:
					index = count - 1 - (index % count);
				case SequenceMode.pingpongReverse:
					var n = (count << 1) - 2;
					index = n == 0 ? 0 : (index + count - 1) % n;
					if (index >= count)
						index = n - index;
			}
		}
		slot.sequenceIndex = index;
	}
}