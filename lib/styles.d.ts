declare namespace imbacss {

    interface _ {

    }

    interface Ψnumber {

    }

    interface Ψpercentage {

    }

    interface Ψlength {

    }



    interface ΨlineΞwidth {
        thin: 'thin'
        medium: 'medium'
        thick: 'thick'
    }

    interface ΨlineΞstyle {
        none: 'none'
        hidden: 'hidden'
        dotted: 'dotted'
        dashed: 'dashed'
        solid: 'solid'
        double: 'double'
        groove: 'groove'
        ridge: 'ridge'
        inset: 'inset'
        outset: 'outset'
    }

    interface Ψcolor {

    }

    interface Ψposition {
        center: 'center'
        top: 'top'
        left: 'left'
        right: 'right'
        bottom: 'bottom'
    }

    interface Ψstring {

    }

    interface Ψimage {

    }

    interface Ψrepeat {

    }

    interface Ψbox {

    }

    interface Ψfont {
        sans: 'Sans serif'
        mono: 'monospace'
        serif: 'serif'
    }

    interface Ψtime {

    }

    interface ΨtimingΞfunction {
        easeΞin: ''
        easeΞout: ''
        easeΞinΞout: ''
        linear: ''
    }

    interface Ψproperty {

    }

    interface Ψidentifier {

    }

    interface Ψurl {

    }

    interface Ψinteger {

    }

    interface ΨunicodeΞrange {

    }

    interface ΨgeometryΞbox {

    }

    interface Ψshape {

    }

    interface Ψangle {

    }

    interface Ψglobals {
        inherit: 'inherit'
        initial: 'initial'
        unset: 'unset'
    }

    interface Ψradius {
        /** @detail 100% */ full: '9999px';
        /** @detail 1px */ xxs: '1px';
        /** @detail 2px */ xs: '2px';
        /** @detail 3px */ sm: '3px';
        /** @detail 4px */ md: '4px';
        /** @detail 6px */ lg: '6px';
        /** @detail 8px */ xl: '8px';
    }


    interface Ψspacing {

    }

    interface Ψdimension {

    }

    // custom properties
    interface px extends _ {
        set(x: Ψspacing): void;
        set(left: Ψspacing, right: Ψspacing): void;
    }

    // custom properties
    interface py extends _ {
        set(y: Ψspacing): void;
        set(top: Ψspacing, bottom: Ψspacing): void;
    }

    // custom properties
    interface mx extends _ {
        set(x: Ψspacing): void;
        set(left: Ψspacing, right: Ψspacing): void;
    }

    interface my extends _ {
        set(y: Ψspacing): void;
        set(top: Ψspacing, bottom: Ψspacing): void;
    }

    /** @detail width & height */
    interface size extends _ {
        set(y: Ψdimension): void;
    }

    /** @detail justify items & content */
    interface j extends _ {
        set(value: justifyΞcontent): void;
        set(value: justifyΞitems): void;
    }

    /** @detail align items & content */
    interface a extends _ {
        set(value: alignΞitems): void;
        set(value: alignΞcontent): void;
    }

    /** @detail justify&align items */
    interface jai extends _ {
        set(value: alignΞitems): void;
        set(value: justifyΞitems): void;
    }

    /** @detail justify&align content */
    interface jac extends _ {
        set(value: alignΞcontent): void;
        set(value: justifyΞcontent): void;
    }

    /**
     * @detail justify&align-self
     */
    interface jas extends _ {
        set(value: alignΞself): void;
        set(value: justifyΞself): void;
    }
    /**
     * @detail (justify|align)-(items|content)
     */
    interface ja extends _ {
        set(value: alignΞcontent): void;
        set(value: justifyΞcontent): void;
        set(value: alignΞitems): void;
        set(value: justifyΞitems): void
    }

    /** @detail ◠ border-top-right-radius & border-top-left-radius */
    interface rdt extends _ {
        set(val: Ψradius | Ψlength | Ψpercentage): void;
    }

    /** @detail ⊂ border-top-left-radius & border-bottom-left-radius */
    interface rdl extends rdt {

    }

    /** @detail ◡ border-bottom-left-radius & border-bottom-right-radius */
    interface rdb extends rdt {

    }

    /** @detail ⊃ border-top-right-radius & border-bottom-right-radius */
    interface rdr extends rdt {

    }

    /**
     * Shorthand property combines four of the transition properties into a single property.
     * 
     * Syntax: <single-transition>#

     * 
     * [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/CSS/transition)
     * 
     * @alias tween
    */
    interface transition extends _ {
        set(val: this | Ψtime | Ψproperty | ΨtimingΞfunction): void;
        set(props: this | Ψproperty, duration: Ψtime, timing?: ΨtimingΞfunction, arg3?: any): void;

        /** Every property that is able to undergo a transition will do so. */
        all: ''

        /** background-color, border-color, color, fill, stroke, opacity, box-shadow, transform */
        styles: ''

        /** width, height, left, top, right, bottom, margin, padding */
        sizes: ''

        /** background-color, border-color, color, fill, stroke */
        colors: ''

        /** No property will transition. */
        none: ''
    }

    /** @proxy transition */
    interface tween extends transition { }


    /** Shorthand for setting transform translateX() */
    interface x extends _ {
        set(val: Ψnumber): void;
    }

    /** Shorthand for setting transform translateY() */
    interface y extends x {

    }

    /** Shorthand for setting transform translateZ() */
    interface z extends x {

    }

    /** Shorthand for setting transform skeq-x() */
    interface skewΞx extends _ {
        set(val: Ψnumber): void;
    }
    /** Shorthand for setting transform skeq-y() */
    interface skewΞy extends _ {
        set(val: Ψnumber): void;
    }
    /** Shorthand for setting transform scale-x() */
    interface scaleΞx extends _ {
        set(val: Ψnumber): void;
    }
    /** Shorthand for setting transform scale-y() */
    interface scaleΞy extends _ {
        set(val: Ψnumber): void;
    }
    /** Shorthand for setting transform scale() */
    interface scale extends _ {
        set(val: Ψnumber): void;
    }
    /** Shorthand for setting transform rotate() */
    interface rotate extends _ {
        set(val: Ψnumber): void;
    }

    /** Shorthand for setting transform skeq-y() */
    interface ease extends _ {
        set(duration: Ψtime): void;
        set(timing: ΨtimingΞfunction): void;
        set(duration: Ψtime, timing: ΨtimingΞfunction): void;
    }
    /** Shorthand for setting transform scale-x() */
    interface easeΞtransform extends ease {
    }
    /** Shorthand for setting transform scale-x() */
    interface easeΞcolors extends ease {
    }

    /** Shorthand for setting transform scale-x() */
    interface easeΞopacity extends ease {
    }

    /** @proxy ease */
    interface e extends ease { }

    /** @proxy easeΞtransform */
    interface et extends easeΞtransform { }
    /** @proxy easeΞcolors */
    interface ec extends easeΞcolors { }
    /** @proxy easeΞopacity */
    interface eo extends easeΞopacity { }
}