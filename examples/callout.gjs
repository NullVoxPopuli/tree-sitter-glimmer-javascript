import { LightBulb } from './icons';

export const Callout = <template>
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
