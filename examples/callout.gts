import { LightBulb } from './icons';

import type { TOC } from '@ember/component/template-only';

export const Callout: TOC<{ Blocks: { default: [] } }> = <template>
  <div>
    <LightBulb />
    <div>
      <div>
        {{yield}}
      </div>
    </div>
  </div>
</template>;

export default Callout;
