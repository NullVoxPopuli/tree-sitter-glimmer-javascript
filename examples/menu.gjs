import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { guidFor } from '@ember/object/internals';

import { modifier as eModifier } from 'ember-modifier';
import { cell } from 'ember-resources';
import { getTabster, getTabsterAttribute, setTabsterAttribute, Types } from 'tabster';

import { Popover } from './popover.gts';

const TABSTER_CONFIG_CONTENT = getTabsterAttribute(
  {
    mover: {
      direction: Types.MoverDirections.Both,
      cyclic: true,
    },
    deloser: {},
  },
  true
);

const TABSTER_CONFIG_TRIGGER = {
  deloser: {},
};

const Separator = <template>
  <div role="separator" ...attributes>
    {{yield}}
  </div>
</template>;

/**
 * We focus items on `pointerMove` to achieve the following:
 *
 * - Mouse over an item (it focuses)
 * - Leave mouse where it is and use keyboard to focus a different item
 * - Wiggle mouse without it leaving previously focused item
 * - Previously focused item should re-focus
 *
 * If we used `mouseOver`/`mouseEnter` it would not re-focus when the mouse
 * wiggles. This is to match native menu implementation.
 */
function focusOnHover(e) {
  const item = e.currentTarget;

  if (item instanceof HTMLElement) {
    item?.focus();
  }
}

const Item = <template>
  <button
    type="button"
    role="menuitem"
    {{! @glint-ignore !}}
    {{(if @onSelect (modifier on "click" @onSelect))}}
    {{on "pointermove" focusOnHover}}
    ...attributes
  >
    {{yield}}
  </button>
</template>;

const installContent = eModifier((element, _, { isOpen, triggerElement }) => {
  // focus first focusable element on the content
  const tabster = getTabster(window);
  const firstFocusable = tabster?.focusable.findFirst({
    container: element,
  });

  firstFocusable?.focus();

  // listen for "outside" clicks
  function onDocumentClick(e) {
    if (
      isOpen.current &&
      e.target &&
      !element.contains(e.target) &&
      !triggerElement.current?.contains(e.target)
    ) {
      isOpen.current = false;
    }
  }

  // listen for the escape key
  function onDocumentKeydown(e) {
    if (isOpen.current && e.key === 'Escape') {
      isOpen.current = false;
    }
  }

  document.addEventListener('click', onDocumentClick);
  document.addEventListener('keydown', onDocumentKeydown);

  return () => {
    document.removeEventListener('click', onDocumentClick);
    document.removeEventListener('keydown', onDocumentKeydown);
  };
});

const Content = <template>
  {{#if @isOpen.current}}
    <@PopoverContent
      id={{@contentId}}
      role="menu"
      data-tabster={{TABSTER_CONFIG_CONTENT}}
      tabindex="0"
      {{installContent isOpen=@isOpen triggerElement=@triggerElement}}
      {{on "click" @isOpen.toggle}}
      ...attributes
    >
      {{yield (hash Item=Item Separator=Separator)}}
    </@PopoverContent>
  {{/if}}
</template>;

const trigger = eModifier(
  (element, _, { triggerElement, isOpen, contentId, setHook }) => {
    element.setAttribute('aria-haspopup', 'menu');

    if (isOpen.current) {
      element.setAttribute('aria-controls', contentId);
      element.setAttribute('aria-expanded', 'true');
    } else {
      element.removeAttribute('aria-controls');
      element.setAttribute('aria-expanded', 'false');
    }

    setTabsterAttribute(element, TABSTER_CONFIG_TRIGGER);

    const onTriggerClick = () => isOpen.toggle();

    element.addEventListener('click', onTriggerClick);

    triggerElement.current = element;
    setHook(element);

    return () => {
      element.removeEventListener('click', onTriggerClick);
    };
  }
);

const Trigger = <template>
  <button type="button" {{@triggerModifier}} ...attributes>
    {{yield}}
  </button>
</template>;

const IsOpen = () => cell(false);
const TriggerElement = () => cell();

export class Menu extends Component {
  contentId = guidFor(this);

  <template>
    {{#let (IsOpen) (TriggerElement) as |isOpen triggerEl|}}
      <Popover
        @flipOptions={{@flipOptions}}
        @middleware={{@middleware}}
        @offsetOptions={{@offsetOptions}}
        @placement={{@placement}}
        @shiftOptions={{@shiftOptions}}
        @strategy={{@strategy}}
        @inline={{@inline}}
        as |p|
      >
        {{#let
          (modifier
            trigger
            triggerElement=triggerEl
            isOpen=isOpen
            contentId=this.contentId
            setHook=p.setHook
          )
          as |triggerModifier|
        }}
          {{yield
            (hash
              trigger=triggerModifier
              Trigger=(component Trigger triggerModifier=triggerModifier)
              Content=(component
                Content
                PopoverContent=p.Content
                isOpen=isOpen
                triggerElement=triggerEl
                contentId=this.contentId
              )
              arrow=p.arrow
              isOpen=isOpen.current
            )
          }}
        {{/let}}
      </Popover>
    {{/let}}
  </template>
}

export default Menu;
