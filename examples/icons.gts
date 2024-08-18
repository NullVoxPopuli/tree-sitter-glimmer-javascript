import type { TOC } from '@ember/component/template-only';

export const XTwitter: TOC<{ Element: SVGElement }> = <template>
  <svg aria-hidden="true" ...attributes>
    <use xlink:href="#social-xtwitter" />
  </svg>
</template>;

export const Discord: TOC<{ Element: SVGElement }> = <template>
  <svg aria-hidden="true" ...attributes>
    <use xlink:href="#social-discord" />
  </svg>
</template>;
