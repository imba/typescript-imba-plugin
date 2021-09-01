/// import {HTML} from './imba.dom';
/// <reference path="./imba.types.d.ts" />
/// <reference path="./imba.dom.d.ts" />
/// <reference path="./imba.css.d.ts" />
/// <reference path="./imba.css.types.d.ts" />
/// <reference path="./imba.css.theme.d.ts" />
/// <reference path="./css.d.ts" />
/// <reference path="./imba.css.custom.d.ts" />
/// <reference path="./imba.events.d.ts" />
/// <reference path="./imba.router.d.ts" />
/// <reference path="./imba.snippets.d.ts" />

type Selector = string;

interface Element {
    /**
     * Schedule this element to render after imba.commit()
     */
    schedule(): this;
    unschedule(): this;
    data: any;
    hotkey: any;
    hotkey__: any;
    route: any;
    route__: any;
    router: ImbaRouter;
    $key: any;

    // itemid: any;
    // itemprop: any;
    // itemref: any;
    // itemscope: any;
    // itemtype: any;
    // enterkeyhint: any;
    // autofocus: any;
    // autocapitalize: any;
    // autocomplete: any;
    // accesskey: any;
    // inputmode: any;
    // spellcheck: any;
    // translate: any;
    // is: any;

    flags: {
        contains(flag: string): boolean;
        add(flag: string): void;
        remove(flag: string): void;
        toggle(flag: string, toggler: boolean): void;
        incr(flag: string): number;
        decr(flag: string): number;
    }

    emit(event: string, params?: any, options?: any): Event;
    focus(options?: any): void;
    blur(): void;

    // [key: string]: any;

    setAttribute(name: string, value: boolean): void;
    setAttribute(name: string, value: number): void;

    addEventListener(event: string, listener: (event: Event) => void, options?: {
        passive?: boolean;
        once?: boolean;
        capture?: boolean;
    });

    removeEventListener(event: string, listener: (event: Event) => void, options?: {
        passive?: boolean;
        once?: boolean;
        capture?: boolean;
    });

    log(...arguments: any[]): void;
}

interface HTMLMetaElement {
    property?: string;
}

interface EventListenerOptions {
    passive?: boolean;
    once?: boolean;
}

interface Storage {
    setItem(key: string, value: number): void;
}

interface HTMLStyleElement {
    /**
     * The supplied path will be run through the imba bundler
     */
    src: ImbaAsset | string;
}

interface SVGSVGElement {
    /**
     * Reference to svg asset that will be inlined
     */
    src: ImbaAsset | string;
}

declare class ΤObject {
    [key: string]: any;
}

declare class ImbaElement extends HTMLElement {
    /**
  * Creates an instance of documenter.
  */
    suspend(): this;
    unsuspend(): this;

    /** Return false if component should not render */
    get renderΦ(): boolean;
    /** True if component is currently being mounted */
    get mountingΦ(): boolean;
    /** True if component is currently mounted in document */
    get mountedΦ(): boolean;
    /** True if component has been awakened */
    get awakenedΦ(): boolean;
    /** True if component has been rendered */
    get renderedΦ(): boolean;
    /** True if component has been suspended */
    get suspendedΦ(): boolean;
    /** True if component is currently rendering */
    get renderingΦ(): boolean;
    /** True if component is scheduled to automatically render */
    get scheduledΦ(): boolean;
    /** True if component has been hydrated on the client */
    get hydratedΦ(): boolean;
    /** True if component was originally rendered on the server */
    get ssrΦ(): boolean;

    schedule(): this;
    unschedule(): this;

}


/** Portal to declare window/document event handlers from
 * inside custom tags.
 */
declare class Γglobal extends HTMLElement {

}

declare class Γteleport extends HTMLElement {
    /** The element (or selector) you want to add listeners and content to */
    to: Selector | Element;
}

interface HTMLElementTagNameMap {
    "global": Γglobal,
    "teleport": Γteleport
}

interface ImbaStyles {
    [key: string]: any;
}

interface ImbaAsset {
    body: string;
    url: string;
    absPath: string;
    path: string;
}

interface Event {
    detail: any;
    originalEvent: Event | null;
}

// interface Object {
//     [key: string]: any;
// }

declare namespace imba {

    function setInterval(handler: TimerHandler, timeout?: number, ...arguments: any[]): number;
    function setTimeout(handler: TimerHandler, timeout?: number, ...arguments: any[]): number;
    function clearInterval(handle?: number): void;
    function clearTimeout(handle?: number): void;
    function commit(): Promise<void>;
    function render(): Promise<void>;

    function mount<T>(element: T): T;

    interface Scheduler {
        add(target: any, force?: boolean): void;
        on(group: string, target: any): void;
        un(group: string, target: any): void;

        /** Milliseconds since previous tick */
        dt: number;
    }

    let styles: ImbaStyles;
    let colors: string[];
    let router: ImbaRouter;

    namespace types {
        let events: GlobalEventHandlersEventMap;
        let eventHandlers: GlobalEventHandlers;

        namespace html {
            let tags: HTMLElementTagNameMap;
            let events: GlobalEventHandlersEventMap;
        }

        namespace svg {
            let tags: SVGElementTagNameMap;
            let events: SVGElementEventMap;
        }
    }

    let stylemodifiers: ImbaStyleModifiers;
    let Element: ImbaElement;
    let scheduler: Scheduler;

    function createIndexedFragment(...arguments: any[]): DocumentFragment;
    function createKeyedFragment(...arguments: any[]): DocumentFragment;
    function createLiveFragment(...arguments: any[]): DocumentFragment;

    function emit(source: any, event: string, params: any[]): void;
    function listen(target: any, event: string, listener: any, path?: any): void;
    function once(target: any, event: string, listener: any, path?: any): void;
    function unlisten(target: any, event: string, listener: any, path?: any): void;
    function indexOf(target: any, source: any): boolean;
    function serve(target: any, options?: any): any;
}

declare module "data:text/asset;*" {
    const value: ImbaAsset;
    export default value;
    export const body: string;
    export const url: string;
    export const absPath: string;
    export const path: string;
}

declare module "imba/compiler" {
    export function compile(fileName: string, options: any): any;
}

declare module "imba" {
    export function compile(fileName: string, options: any): any;
}