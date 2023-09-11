package spine.animation;

import openfl.Vector;

class RGBATimeline extends CurveTimeline implements SlotTimeline {
	private static inline var ENTRIES:Int = 5;
	private static inline var R:Int = 1;
	private static inline var G:Int = 2;
	private static inline var B:Int = 3;
	private static inline var A:Int = 4;

	private var slotIndex:Int = 0;

	public function new(frameCount:Int, bezierCount:Int, slotIndex:Int) {
		super(frameCount, bezierCount, Vector.ofArray([Property.rgb + "|" + slotIndex, Property.alpha + "|" + slotIndex]));
		this.slotIndex = slotIndex;
	}

	public override function getFrameEntries():Int {
		return ENTRIES;
	}

	public function getSlotIndex():Int {
		return slotIndex;
	}

	/** Sets the time in seconds, light, and dark colors for the specified key frame. */
	public function setFrame(frame:Int, time:Float, r:Float, g:Float, b:Float, a:Float):Void {
		frame *= ENTRIES;
		frames[frame] = time;
		frames[frame + R] = r;
		frames[frame + G] = g;
		frames[frame + B] = b;
		frames[frame + A] = a;
	}

	public override function apply(skeleton:Skeleton, lastTime:Float, time:Float, events:Vector<Event>, alpha:Float, blend:MixBlend,
			direction:MixDirection):Void {
		var slot:Slot = skeleton.slots[slotIndex];
		if (!slot.bone.active)
			return;

		var color:Color = slot.color;
		if (time < frames[0]) {
			var setup:Color = slot.data.color;
			switch (blend) {
				case MixBlend.setup:
					color.setFromColor(setup);
				case MixBlend.first:
					color.add((setup.r - color.r) * alpha, (setup.g - color.g) * alpha, (setup.b - color.b) * alpha, (setup.a - color.a) * alpha);
			}
			return;
		}

		var r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 0;
		var i:Int = Timeline.search(frames, time, ENTRIES);
		var curveType:Int = Std.int(curves[Std.int(i / ENTRIES)]);
		switch (curveType) {
			case CurveTimeline.LINEAR:
				var before:Float = frames[i];
				r = frames[i + R];
				g = frames[i + G];
				b = frames[i + B];
				a = frames[i + A];
				var t:Float = (time - before) / (frames[i + ENTRIES] - before);
				r += (frames[i + ENTRIES + R] - r) * t;
				g += (frames[i + ENTRIES + G] - g) * t;
				b += (frames[i + ENTRIES + B] - b) * t;
				a += (frames[i + ENTRIES + A] - a) * t;
			case CurveTimeline.STEPPED:
				r = frames[i + R];
				g = frames[i + G];
				b = frames[i + B];
				a = frames[i + A];
			default:
				r = getBezierValue(time, i, R, curveType - CurveTimeline.BEZIER);
				g = getBezierValue(time, i, G, curveType + CurveTimeline.BEZIER_SIZE - CurveTimeline.BEZIER);
				b = getBezierValue(time, i, B, curveType + CurveTimeline.BEZIER_SIZE * 2 - CurveTimeline.BEZIER);
				a = getBezierValue(time, i, A, curveType + CurveTimeline.BEZIER_SIZE * 3 - CurveTimeline.BEZIER);
		}

		if (alpha == 1) {
			color.set(r, g, b, a);
		} else {
			if (blend == MixBlend.setup)
				color.setFromColor(slot.data.color);
			color.add((r - color.r) * alpha, (g - color.g) * alpha, (b - color.b) * alpha, (a - color.a) * alpha);
		}
	}
}