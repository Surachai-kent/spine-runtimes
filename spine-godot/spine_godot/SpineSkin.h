/******************************************************************************
 * Spine Runtimes License Agreement
 * Last updated January 1, 2020. Replaces all prior versions.
 *
 * Copyright (c) 2013-2020, Esoteric Software LLC
 *
 * Integration of the Spine Runtimes into software or otherwise creating
 * derivative works of the Spine Runtimes is permitted under the terms and
 * conditions of Section 2 of the Spine Editor License Agreement:
 * http://esotericsoftware.com/spine-editor-license
 *
 * Otherwise, it is permitted to integrate the Spine Runtimes into software
 * or otherwise create derivative works of the Spine Runtimes (collectively,
 * "Products"), provided that each user of the Products must obtain their own
 * Spine Editor license and redistribution of the Products in any form must
 * include this license and copyright notice.
 *
 * THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
 * BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THE SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

#ifndef GODOT_SPINESKIN_H
#define GODOT_SPINESKIN_H

#include "core/variant_parser.h"

#include <spine/spine.h>

#include "SpineAttachment.h"
#include "SpineSkinAttachmentMapEntries.h"

class SpineSkin : public Reference {
	GDCLASS(SpineSkin, Reference);

protected:
	static void _bind_methods();

private:
	spine::Skin *skin;

public:
	SpineSkin();
	~SpineSkin();

	inline void set_spine_object(spine::Skin *s) {
		skin = s;
	}
	spine::Skin *get_spine_object() {
		return skin;
	}

	Ref<SpineSkin> init(const String &name);

	void set_attachment(uint64_t slot_index, const String &name, Ref<SpineAttachment> attachment);

	Ref<SpineAttachment> get_attachment(uint64_t slot_index, const String &name);

	void remove_attachment(uint64_t slot_index, const String &name);

	Array find_names_for_slot(uint64_t slot_index);

	Array find_attachments_for_slot(uint64_t slot_index);

	String get_skin_name();

	void add_skin(Ref<SpineSkin> other);

	void copy_skin(Ref<SpineSkin> other);

	Ref<SpineSkinAttachmentMapEntries> get_attachments();

	Array get_bones();

	Array get_constraint();
};

#endif//GODOT_SPINESKIN_H