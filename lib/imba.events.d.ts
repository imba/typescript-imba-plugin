
type FlagTarget = Element | Document | string;

interface Event {
    /**
     Tells the browser that the default action should not be taken. The event will still continue to propagate up the tree. See Event.preventDefault()
    @see https://imba.io/events/event-modifiers#core-prevent
    */
    αprevent(): void;
    /**
     Stops the event from propagating up the tree. Event listeners for the same event on nodes further up the tree will not be triggered. See Event.stopPropagation()
    */
    αstop(): void;
    /**
     * Indicates that the listeners should be invoked at most once. The listener will automatically be removed when invoked.
     */
    αonce(): void;
    
    /**
     * Indicating that events of this type should be dispatched to the registered listener before being dispatched to tags deeper in the DOM tree.
     */
    αcapture(): void;

    αpassive(): void;

    // αsilence(): void;
    
    /**
     * Don't trigger imba.commit from this event handler
     */
    αsilent(): void;
    
    
    /** The wait modifier delays the execution of subsequent modifiers and callback. It defaults to wait for 250ms, which can be overridden by passing a number or time as the first/only argument. 
     * @detail (time = 500ms)
     */
    αwait(time?: Time): void;

    /**
     * Hello there
     * @detail (time = 500ms)
     */
    αthrottle(time?: Time): void;

    /**
     * Hello there
     * @detail (time = 500ms)
     */
    αdebounce(time?: Time): void;


    /** 
     * Only trigger handler if event.target is the element itself 
     * 
     */
    αself(): boolean;

    /** 
     * Only trigger handler if event.target matches selector
     * @detail (selector)
     * */
    αsel(selector: string): boolean;

    /**
     * Only trigger condition is truthy
     * @detail (condition)
     * */
    αif(condition: unknown): boolean;
    
    /**
     * Trigger another event via this handler
     * @param name The name of the event to trigger
     * @param detail Data associated with the event
     * @detail (name,detail = {})
     * */
    αemit(name: string, detail?: any): void;
     /**
     * Trigger another event via this handler
     * @param detail Data associated with the event
     * */
    αemitΞname(detail?: any): void;
    
    /**
     * Add an html class to target for at least 250ms
     * If the callback returns a promise, the class
     * will not be removed until said promise has resolved
     * @param name the class to add
     * @param target the element on which to add the class. Defaults to the element itself
     * */
    αflag(name: string, target?: FlagTarget): void;
    
    /**
     * Add an html class to target for at least 250ms
     * If the callback returns a promise, the class
     * will not be removed until said promise has resolved
     * @param target the element on which to add the class. Defaults to the element itself
     **/
    αflagΞname(target?: FlagTarget): void;

    /**
     * Logs to console
     * @detail (...data)
     */
    αlog(...data: any[]): void;
}

interface MouseEvent {
    /**
    * Only if ctrl key is pressed 
    *
    */
    αctrl(): boolean;

    /**
    * Only if alt key is pressed 
    *
    */
    αalt(): boolean;

    /**
    * Only if shift key is pressed 
    *
    */
    αshift(): boolean;

    /**
    * Only if meta key is pressed 
    *
    */
    αmeta(): boolean;
    
    /**
    * Only if middle button is pressed
    *
    */
    αmiddle(): boolean;
    
    /**
    * Only if left/primary button is pressed
    *
    */
    αleft(): boolean;
    
    /**
    * Only if right button is pressed
    *
    */
    αright(): boolean;
}


interface KeyboardEvent {
    /**
    * Only if enter key is pressed 
    *
    */
    αenter(): boolean;

    /**
    * Only if left key is pressed 
    *
    */
    αleft(): boolean;

    /**
    * Only if right key is pressed 
    *
    */
    αright(): boolean;

    /**
    * Only if up key is pressed 
    *
    */
    αup(): boolean;

    /**
    * Only if down key is pressed 
    *
    */
    αdown(): boolean;

    /**
    * Only if tab key is pressed 
    *
    */
    αtab(): boolean;

    /**
    * Only if esc key is pressed 
    *
    */
    αesc(): boolean;

    /**
    * Only if space key is pressed 
    *
    */
    αspace(): boolean;

    /**
    * Only if del key is pressed 
    *
    */
    αdel(): boolean;
    
    /**
    * Only if keyCode == code
    */
    αkey(code:number): boolean;
}

interface PointerEvent {
    /**
    * Only mouse 
    *
    */
    αmouse(): boolean;

    /**
    * Only pen 
    *
    */
    αpen(): boolean;

    /**
    * Only hand/fingers 
    *
    */
    αtouch(): boolean;
    
    /**
    * Only when pressure is at least amount (defaults to 0.5)
    */
    αpressure(amount?:number): boolean;
}

type ModifierElementTarget = Element | string;

declare class ImbaTouch extends PointerEvent {
    
    /** True if touch is still active */
    get activeΦ(): boolean;
    
    /** True if touch has ended */
    get endedΦ(): boolean;

    /**
    * Only when touch has moved more than threshold
    * @detail (threshold = 4px)
    */
    αmoved(threshold?: Length): boolean;


    /**
    * Only when touch has moved left or right more than threshold
    * @detail (threshold = 4px)
    */
    αmovedΞx(threshold?: Length): boolean;

    /**
    * Only when touch has moved up or down more than threshold
    * @detail (threshold = 4px)
    */
    αmovedΞy(threshold?: Length): boolean;

    /**
    * Only when touch has moved up more than threshold
    * @detail (threshold = 4px)
    */
    αmovedΞup(threshold?: Length): boolean;

    /**
    * Only when touch has moved down more than threshold
    * @detail (threshold = 4px)
    */
    αmovedΞdown(threshold?: Length): boolean;

    /**
     * A convenient touch modifier that takes care of updating the x,y values of some data during touch. When touch starts sync will remember the initial x,y values and only add/subtract based on movement of the touch.
     * 
     * @see https://imba.io/events/touch-events#modifiers-sync
     * @detail (data, xProp?, yProp?)
     */
    αsync(data: object, xName?: string | null, yName?: string | null): boolean;
    
    /**
     * Sets the x and y properties of object to the x and y properties of touch.
     * 
     * @see https://imba.io/events/touch-events#modifiers-apply
     * @detail (data, xProp?, yProp?)
     */
    αapply(data: object, xName?: string | null, yName?: string | null): boolean;

    /**
    * Convert the coordinates of the touch to some other frame of reference.
    * @detail (target?,snap?)
    */
    αfit(): void;
    αfit(start: Length, end: Length, snap?: number): void;
    αfit(target: ModifierElementTarget): void;
    αfit(target: ModifierElementTarget, snap?: number): void;
    αfit(target: ModifierElementTarget, snap?: number): void;
    αfit(target: ModifierElementTarget, start: Length, end: Length, snap?: number): void;

    /**
    * Just like @touch.fit but without clamping x,y to the bounds of the
    * target.
    * @detail (target?, ax?, ay?)
    */
    αreframe(): void;
    αreframe(start: Length, end: Length, snap?: number): void;
    αreframe(context: Element | string, snap?: number): void;
    αreframe(context: Element | string, start: Length, end: Length, snap?: number): void;

    /**
    * Allow pinning the touch to a certain point in an element, so that
    * all future x,y values are relative to this pinned point.
    * @detail (target?, ax?, ay?)
    */
    αpin(): void;
    αpin(target: ModifierElementTarget): void;
    αpin(target: ModifierElementTarget, anchorX?: number, anchorY?: number): void;

    /**
    * Round the x,y coordinates with an option accuracy
    * @detail (to = 1)
    */
    αround(nearest?: number): void;
}


type IntersectRoot = Element | Document;

type IntersectOptions = {
    rootMargin?: string;
    root?: IntersectRoot;
    thresholds?: number[];
}


declare class ImbaIntersectEvent extends Event {
    /**
    * @detail only when intersection increases
    */
    αin(): boolean;

    /**
    * @detail only when intersection decreases
    */
    αout(): boolean;

    αcss(): void;
    
    /**
    * Will add a class to the DOM element whenever it is intersecting
    * @param name The class-name to add
    */
    αflag(name: string): void;
    αflagΞname(): void;
    
    /**
    * Will add a class to the DOM element whenever it is intersecting
    * @param root reference to the parent
    * @param thresholds 0-1 for a single threshold, 2+ for n slices

    */
    αoptions(root?: IntersectRoot, thresholds?: number): void;
    
    
    αoptions(thresholds?: number): void;
    αoptions(rootMargin: string, thresholds?: number): void;
    αoptions(rootMargin: string, thresholds?: number): void;
    αoptions(options: IntersectOptions): void;
    
    
    /**
    * The raw IntersectionObserverEntry 
    *
    */
    entry: IntersectionObserverEntry;
    /**
    * Ratio of the intersectionRect to the boundingClientRect 
    *
    */
    ratio: number;
    /**
    * Difference in ratio since previous event 
    *
    */
    delta: number;
}

declare class ImbaHotkeyEvent extends Event {
    
    /**
     * 
     * @param pattern string following pattern from mousetrap
     * @see https://craig.is/killing/mice 
     */
    αoptions(pattern:string): void;
    
    /**
    * Also trigger when input,textarea or a contenteditable is focused
    */
    αcapture(): void;

    /**
    * Trigger even if outside of the originating hotkey group
    */
    αglobal(): void;
    
    /**
    * Allow subsequent hotkey handlers for the same combo
    * and don't automatically prevent default behaviour of originating
    * keyboard event
    */
    αpassive(): void;
}

declare class ImbaResizeEvent extends UIEvent {
    width: number;
    height: number;
    rect: DOMRectReadOnly;
    entry: ResizeObserverEntry;
}

declare class ImbaSelectionEvent extends Event {
    detail: {
        start: number;
        end: number;
    }
}


interface GlobalEventHandlersEventMap {
    "touch": ImbaTouch;
    "intersect": ImbaIntersectEvent;
    "selection": ImbaSelectionEvent;
    "hotkey": ImbaHotkeyEvent;
    "resize": ImbaResizeEvent;
    "__unknown": CustomEvent;
}

interface HTMLElementEventMap {
    "resize": ImbaResizeEvent;
}

interface ImbaEvents {
    /**
    * The loading of a resource has been aborted. 
    *
    */
    abort: UIEvent;
    animationcancel: AnimationEvent;
    /**
    * A CSS animation has completed. 
    *
    */
    animationend: AnimationEvent;
    /**
    * A CSS animation is repeated. 
    *
    */
    animationiteration: AnimationEvent;
    /**
    * A CSS animation has started. 
    *
    */
    animationstart: AnimationEvent;

    auxclick: MouseEvent;
    /**
    * An element has lost focus (does not bubble). 
    *
    */
    blur: FocusEvent;

    cancel: Event;
    /**
    * The user agent can play the media, but estimates that not enough data has been loaded to play the media up to its end without having to stop for further buffering of content. 
    *
    */
    canplay: Event;
    /**
    * The user agent can play the media up to its end without having to stop for further buffering of content. 
    *
    */
    canplaythrough: Event;
    /**
    * The change event is fired for <input>, <select>, and <textarea> elements when a change to the element's value is committed by the user. 
    *
    */
    change: Event;
    /**
    * A pointing device button has been pressed and released on an element. 
    *
    */
    click: MouseEvent;
    close: Event;
    contextmenu: MouseEvent;
    cuechange: Event;
    dblclick: MouseEvent;
    drag: DragEvent;
    dragend: DragEvent;
    dragenter: DragEvent;
    dragexit: Event;
    dragleave: DragEvent;
    dragover: DragEvent;
    dragstart: DragEvent;
    drop: DragEvent;
    durationchange: Event;
    emptied: Event;
    ended: Event;
    error: ErrorEvent;
    focus: FocusEvent;
    focusin: FocusEvent;
    focusout: FocusEvent;
    gotpointercapture: PointerEvent;
    input: Event;
    invalid: Event;
    intersect: ImbaIntersectEvent;
    keydown: KeyboardEvent;
    keypress: KeyboardEvent;
    keyup: KeyboardEvent;
    load: Event;
    loadeddata: Event;
    loadedmetadata: Event;
    loadstart: Event;
    lostpointercapture: PointerEvent;
    mousedown: MouseEvent;
    mouseenter: MouseEvent;
    mouseleave: MouseEvent;
    mousemove: MouseEvent;
    mouseout: MouseEvent;
    mouseover: MouseEvent;
    mouseup: MouseEvent;
    pause: Event;
    play: Event;
    playing: Event;
    pointercancel: PointerEvent;
    pointerdown: PointerEvent;
    pointerenter: PointerEvent;
    pointerleave: PointerEvent;
    pointermove: PointerEvent;
    pointerout: PointerEvent;
    pointerover: PointerEvent;
    pointerup: PointerEvent;
    progress: ProgressEvent;
    ratechange: Event;
    reset: Event;
    resize: ImbaResizeEvent;
    scroll: Event;
    securitypolicyviolation: SecurityPolicyViolationEvent;
    seeked: Event;
    seeking: Event;
    select: Event;
    selectionchange: Event;
    selectstart: Event;
    stalled: Event;
    submit: Event;
    suspend: Event;
    timeupdate: Event;
    toggle: Event;
    touch: ImbaTouch;
    hotkey: ImbaHotkeyEvent;
    touchcancel: TouchEvent;
    touchend: TouchEvent;
    touchmove: TouchEvent;
    touchstart: TouchEvent;
    transitioncancel: TransitionEvent;
    transitionend: TransitionEvent;
    transitionrun: TransitionEvent;
    transitionstart: TransitionEvent;
    volumechange: Event;
    waiting: Event;
    wheel: WheelEvent;
    [event: string]: CustomEvent;
}